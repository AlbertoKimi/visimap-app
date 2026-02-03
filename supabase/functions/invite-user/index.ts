import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, PUT, DELETE',
}

Deno.serve(async (req) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    // Health check endpoint
    if (req.method === 'GET') {
        return new Response(JSON.stringify({ status: 'Function is ALIVE' }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 200
        })
    }

    try {
        const { email, options } = await req.json()

        // 1. Get the Service Role Key
        const supabaseUrl = Deno.env.get('SUPABASE_URL')
        const serviceRoleKey = Deno.env.get('SERVICE_ROLE_KEY')

        // 2. Check if the key exists
        if (!supabaseUrl || !serviceRoleKey) {
            console.error("Missing Environment Variables. URL:", !!supabaseUrl, "Key:", !!serviceRoleKey)
            return new Response(JSON.stringify({
                error: "Server Configuration Error: Missing SERVICE_ROLE_KEY. Please set this secret in Supabase."
            }), {
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                status: 500,
            })
        }

        const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey)

        const { data, error } = await supabaseAdmin.auth.admin.inviteUserByEmail(
            email,
            options
        )

        if (error) {
            console.error("Supabase Invite Error:", error)
            throw error
        }

        return new Response(JSON.stringify(data), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 200,
        })

    } catch (error) {
        console.error("Function Error:", error)
        return new Response(JSON.stringify({ error: error.message || "Unknown error" }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 400,
        })
    }
})
