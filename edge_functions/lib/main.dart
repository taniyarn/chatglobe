import 'dart:convert';

import 'package:supabase_functions/supabase_functions.dart';

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
      "authorization, x-client-info, apikey, content-type"
};

void main() {
  SupabaseFunctions(fetch: (request) async {
    if (request.method == 'OPTIONS') {
      return Response(
        "ok",
        headers: Headers(corsHeaders),
      );
    }
    final req = (await request.json()) as Map<String, dynamic>?;

    if (req == null) {
      return Response.error();
    }
    final Response data = await fetch(
      Resource.uri(Uri.parse('https://api.openai.com/v1/completions')),
      method: 'POST',
      headers: Headers(
        {
          'Authorization': 'Bearer ${Deno.env.get('OPENAI_API_KEY')}',
          'OpenAI-Organization': '${Deno.env.get('ORGANIZATION_ID')}',
          'Content-Type': 'application/json'
        },
      ),
      body: jsonEncode(<String, dynamic>{
        'model': 'text-davinci-003',
        'prompt':
            'Translate the inputted content into the language specified by the given language.　language: ${req['language']}, Content: ${req['content']}',
        'max_tokens': 256,
        'temperature': 0,
        'stream': false,
      }),
    );
    final json = await data.json();

    return Response.json(json,
        headers: Headers({
          'Content-Type': 'application/json',
          ...corsHeaders,
        }));
  });
}
