use v5.42;
use utf8;
use experimental qw(class);

use Pono::Request;
use Pono::Response;
use Pono::Context;

my $not_found_handler = sub ($c) {
    return $c->text('Not Found', 404);
};

my $error_handler = sub ($err, $c) {
    if ($err->can('get_response')) {
        return $err->get_response();
    }
    warn $err;
    return $c->text('Internal Server Error', 500);
};

class Pono::Base {
    field $router :param = undef; # isa Pono::Router
    field $routes :reader = []; # isa ArrayRef[RouterRoute]

    field $Variables :param = undef; # Type for c.set/get. e.g. { key1 => Int, key2 => Str }

    field $not_found_handler = $not_found_handler;
    field $error_handler = $error_handler;

    # Declare private methods
    my method handle_error;
    my method add_route;
    my method match_route;
    my method dispatch;

    method not_found($handler) {
        $not_found_handler = $handler;
        return $self;
    }

    method on_error($handler) {
        $error_handler = $handler;
        return $self;
    }

    method router($r = undef) {
        if ($r) { $router = $r }
        $router;
    }

    method get($path, $handler) {
        $self->&add_route('GET', $path, $handler);
    }

    method post($path, $handler) {
        $self->&add_route('POST', $path, $handler);
    }

    method put($path, $handler) {
        $self->&add_route('PUT', $path, $handler);
    }

    method delete($path, $handler) {
        $self->&add_route('DELETE', $path, $handler);
    }

    method patch($path, $handler) {
        $self->&add_route('PATCH', $path, $handler);
    }

    method options($path, $handler) {
        $self->&add_route('OPTIONS', $path, $handler);
    }



    method psgi() {
        sub ($env) {
            my $req = Pono::Request->new(env => $env);
            my $res = $self->&dispatch($req, uc $req->method);
            $res->finalize;
        }
    }

    method get_path($request) {
        # TODO: base path
        $request->path;
    }

    method request($http_request) {
        require Pono::Test;
        my $test = Pono::Test->new(app => $self);
        my $res = $test->request($http_request);
        $res;
    }



    # Following methods are private
    # -----------------------------

    method handle_error($err, $c, $error_handler) {
        if (blessed($err)) {
            return $error_handler->($err, $c);
        }
        Carp::croak $err;
    }

    method add_route($method, $path, $handler) {
        $method = uc $method;
        my $r = { path => $path, method => $method, handler => $handler };
        $self->router->add($method, $path, [$handler, $r]);
        push $self->routes->@*, $r;
        return $self;
    }

    method match_route($method, $path) {
        return $self->router->match($method, $path);
    }

    method dispatch($request, $method) {
        if ($method eq 'HEAD') {
            # Handle HEAD method
            my $res = $self->&dispatch($request, 'GET');
            return Pono::Response->new(
                code    => $res->code,
                headers => $res->headers,
            );
        }

        my $path = $self->get_path($request);
        my $match_result = $self->&match_route($method, $path);

        my $c = Pono::Context->new(
            request      => $request,
            response     => Pono::Response->new,
            match_result => $match_result,
            not_found_handler => $not_found_handler,
            Variables    => $Variables,
        );
        my $match_handlers = $match_result->[0];

        if ($match_handlers->@* == 1) {
            my $res; # ReturnType
            try {
                $res = $match_handlers->[0][0][0]->($c);
            }
            catch ($err) {
                return $self->&handle_error($err, $c, $error_handler);
            }

            return $res // $not_found_handler->($c);
            # TODO Promise
        }

        # TODO compose handlers

        $not_found_handler->($c);
    }

}
