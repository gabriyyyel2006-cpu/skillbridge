
import "@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "@supabase/server";

const json = (body: Record<string, unknown>, status = 200) =>
  Response.json(body, { status });

const uuidPattern =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function getBanDuration(endsAt: string | null): string {
  if (endsAt === null) return "876000h";

  const seconds = Math.ceil(
    (new Date(endsAt).getTime() - Date.now()) / 1000,
  );

  if (!Number.isFinite(seconds) || seconds <= 0) {
    throw new Error("Suspension expiry must be in the future.");
  }

  return `${seconds}s`;
}

export default {
  fetch: withSupabase({ auth: "user" }, async (req, ctx) => {
    try {
      if (req.method !== "POST") {
        return json({ error: "Method not allowed." }, 405);
      }

      const adminId = ctx.userClaims?.id;

      if (!adminId) {
        return json({ error: "Authenticated user required." }, 401);
      }

      // Verify actual Admin membership.
      const { data: admin, error: adminError } = await ctx.supabase
        .from("admin_users")
        .select("id")
        .eq("id", adminId)
        .maybeSingle();

      if (adminError || !admin) {
        return json({ error: "Admin access required." }, 403);
      }

      const body = await req.json();
      const { action } = body;

      if (action === "suspend") {
        const { user_id, reason, ends_at = null } = body;

        if (
          typeof user_id !== "string" ||
          !uuidPattern.test(user_id) ||
          typeof reason !== "string" ||
          !reason.trim() ||
          reason.trim().length > 2000
        ) {
          return json({ error: "Invalid suspension details." }, 400);
        }

        if (
          ends_at !== null &&
          (typeof ends_at !== "string" ||
            !Number.isFinite(Date.parse(ends_at)) ||
            Date.parse(ends_at) <= Date.now())
        ) {
          return json({ error: "Invalid suspension expiry." }, 400);
        }

        const duration = getBanDuration(ends_at);

        // Create the authoritative database record first.
        const { data: suspensionId, error: suspendError } =
          await ctx.supabase.rpc("suspend_user_account", {
            p_user_id: user_id,
            p_reason: reason.trim(),
            p_ends_at: ends_at,
          });

        if (suspendError || !suspensionId) {
          return json({ error: "Database suspension failed." }, 400);
        }

        // Apply the corresponding Supabase Auth ban.
        const { error: banError } =
          await ctx.supabaseAdmin.auth.admin.updateUserById(
            user_id,
            { ban_duration: duration },
          );

        if (banError) {
          // Compensate if the Auth operation fails.
          const { error: rollbackError } = await ctx.supabase.rpc(
            "reactivate_user_account",
            {
              p_suspension_id: suspensionId,
              p_remarks: "Automatic rollback: Supabase Auth ban failed.",
            },
          );

          return json({
            error: "Supabase Auth suspension failed.",
            database_rollback: rollbackError ? "failed" : "completed",
          }, 502);
        }

        return json({
          success: true,
          suspension_id: suspensionId,
          message: "Account suspended successfully.",
        });
      }

      
      if (action === "reactivate") {
        const { suspension_id } = body;

        if (
          typeof suspension_id !== "string" ||
          !uuidPattern.test(suspension_id)
        ) {
          return json({ error: "Invalid suspension ID." }, 400);
        }

        const { data: suspension, error: lookupError } =
          await ctx.supabaseAdmin
            .from("account_suspensions")
            .select("id,user_id,ends_at,status")
            .eq("id", suspension_id)
            .maybeSingle();

        if (lookupError || !suspension || suspension.status !== "active") {
          return json({ error: "Active suspension not found." }, 404);
        }

        const { error: unbanError } =
          await ctx.supabaseAdmin.auth.admin.updateUserById(
            suspension.user_id,
            { ban_duration: "none" },
          );

        if (unbanError) {
          return json({ error: "Supabase Auth reactivation failed." }, 502);
        }

        const { error: reactivateError } = await ctx.supabase.rpc(
          "reactivate_user_account",
          {
            p_suspension_id: suspension_id,
            p_remarks: "Admin reactivated account.",
          },
        );

        if (reactivateError) {
          const expiry = suspension.ends_at
            ? new Date(suspension.ends_at).getTime()
            : null;

          const duration =
            expiry !== null && expiry <= Date.now()
              ? null
              : getBanDuration(suspension.ends_at);

          const { error: rollbackError } = duration
            ? await ctx.supabaseAdmin.auth.admin.updateUserById(
                suspension.user_id,
                { ban_duration: duration },
              )
            : { error: null };

          return json({
            error: "Database reactivation failed.",
            auth_rollback: duration
              ? (rollbackError ? "failed" : "completed")
              : "not_needed_expired",
          }, 502);
        }

        return json({
          success: true,
          message: "Account reactivated successfully.",
        });
      }


      return json({ error: "Unsupported action." }, 400);
    } catch (error) {
      console.error("Admin account management error:", error);
      return json({ error: "Account management request failed." }, 500);
    }
  }),
};
