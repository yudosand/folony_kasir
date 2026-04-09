<?php

if (! function_exists('mb_split')) {
    function mb_split(string $pattern, string $string, int $limit = -1): array|false
    {
        $delimitedPattern = '/'.str_replace('/', '\\/', $pattern).'/u';
        $result = preg_split($delimitedPattern, $string, $limit);

        return $result === false ? false : $result;
    }
}
