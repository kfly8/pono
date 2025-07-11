package Pono::Request;
use v5.42;
use utf8;
use experimental qw(class);

use Pono::Util::Request ();

class Pono::Request {
    field $env :param :reader;

    field $_headers;
    field $_query;
    field $_form;
    field $_raw_body;
    field $_json;

    method method() { $env->{REQUEST_METHOD} } # e.g. GET, POST, PUT, DELETE
    method path() { $env->{PATH_INFO} || '/' }

    # get path parameters
    method param($key = undef) { ... } # TODO

    # get query parameters
    method query($key = undef) {
        if (!defined $_query) {
            $_query = Pono::Util::Request::parse_query($env);
        }
        $key ? $_query->{$key} : $_query;
    }

    # get form data
    method form_data($key = undef) {
       if (!defined $_form) {
            $_form = Pono::Util::Request::parse_form_data($env);
        }
        $key ? $_form->{data}{$key} : $_form->{data};
    }

    method upload($key = undef) {
        if (!defined $_form) {
            $_form = Pono::Util::Request::parse_form_data($env);
        }
        $key ? $_form->{uploads}{$key} : $_form->{uploads};
    }

    method json() {
        if (!defined $_json) {
            $_json = Pono::Util::Request::parse_json($env);
        }
        wantarray ? ($_json->{json}, $_json->{json_type}) : $_json->{json};
    }

    method raw_body() {
        if (!defined $_raw_body) {
            $_raw_body = Pono::Util::Request::raw_body($env);
        }
        $_raw_body;
    }

    method header($key = undef) {
        if (!defined $_headers) {
            $_headers = Pono::Util::Request::headers($env);
        }

        $key ? $_headers->header($key) : $_headers;
    }
}
