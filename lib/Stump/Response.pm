use v5.40;
use utf8;
use experimental qw(class);

use HTTP::Headers::Fast;
use Encode ();

class Stump::Response {
    field $code = 200;
    field $headers :reader = HTTP::Headers::Fast->new;
    field $body;

    method header($name, $value=undef) {
        if (defined $value) {
            $headers->header($name, $value);
        }
        $headers->header($name);
    }

    method code($c = undef) {
        if (defined $c) {
            $code = $c;
        }
        $code;
    }

    # alias for code
    method status($s = undef) {
        if (defined $s) {
            $code = $s;
        }
        $code;
    }

    method body($b = undef) {
        if (defined $b) {
            $body = $b;
        }
        $body;
    }

    method finalize {
        return [
            $code,
            $headers->psgi_flatten,
            [Encode::encode_utf8($body)],
        ]
    }
}
