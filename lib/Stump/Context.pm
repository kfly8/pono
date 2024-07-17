use v5.40;
use experimental qw(class);

use Stump::JSON;

class Stump::Context {
    field $request :param :reader;
    field $response :param :reader;
    field $match_result :param :reader;

    method text($code, $text) {
        $self->response->code($code);
        $self->response->header('Content-Type', 'text/plain');
        $self->response->body($text);
        return $self->response;
    }

    method json($code, $data, $spec = undef) {
        my $json = Stump::JSON::encode_json($data, $spec);

        $self->response->code($code);
        $self->response->header('Content-Type', 'application/json');
        $self->response->body($json);
        return $self->response;
    }
}
