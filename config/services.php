<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Third Party Services
    |--------------------------------------------------------------------------
    |
    | This file is for storing the credentials for third party services such
    | as Mailgun, Postmark, AWS and more. This file provides the de facto
    | location for this type of information, allowing packages to have
    | a conventional file to locate the various service credentials.
    |
    */

    'postmark' => [
        'key' => env('POSTMARK_API_KEY'),
    ],

    'resend' => [
        'key' => env('RESEND_API_KEY'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    'slack' => [
        'notifications' => [
            'bot_user_oauth_token' => env('SLACK_BOT_USER_OAUTH_TOKEN'),
            'channel' => env('SLACK_BOT_USER_DEFAULT_CHANNEL'),
        ],
    ],

    'foodukm_auth' => [
        'login_url' => env('FOODUKM_LOGIN_URL', 'https://dev.foodukm.com/app/api_login_v2'),
        'register_url' => env('FOODUKM_REGISTER_URL', 'https://dev.foodukm.com/app/api_registrasi_v2'),
    ],

    'foloni_app_admin' => [
        'login_url' => env('FOLONI_APP_ADMIN_LOGIN_URL', 'https://dev.foodukm.com/adm/user/login'),
        'member_points_url' => env('FOLONI_APP_MEMBER_POINTS_URL', 'https://dev.foodukm.com/adm/finance/poin/member'),
        'point_history_url' => env('FOLONI_APP_POINT_HISTORY_URL', 'https://dev.foodukm.com/adm/finance/poin/history'),
        'point_mutation_url' => env('FOLONI_APP_POINT_MUTATION_URL', 'https://dev.foodukm.com/adm/finance/poin'),
        'user' => env('FOLONI_APP_ADMIN_USER'),
        'password' => env('FOLONI_APP_ADMIN_PASSWORD'),
        'token_cache_minutes' => (int) env('FOLONI_APP_ADMIN_TOKEN_CACHE_MINUTES', 30),
    ],

];
