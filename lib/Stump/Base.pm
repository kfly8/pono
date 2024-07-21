use v5.40;
use utf8;
use experimental qw(class);

use Stump::Request;
use Stump::Response;
use Stump::Context;

class Stump::Base {
    field $router :param = undef; # isa Stump::Router
    field $routes :reader = []; # isa ArrayRef[RouterRoute]

    field $not_found_handler = sub ($c) {
        return $c->text(404, 'Not Found');
    };

    my sub add_route($self, $method, $path, $handler) {
        $method = uc $method;
        my $r = { path => $path, method => $method, handler => $handler };
        $self->router->add($method, $path, [$handler, $r]);
        push $self->routes->@*, $r;
    }

    my sub match_route($self, $method, $path) {
        return $self->router->match($method, $path);
    }

    my sub dispatch($self, $request, $opts = {}) {
        my $path = $self->get_path($request);
        my $match_result = match_route($self, $request->method, $path);

        my $c = Stump::Context->new(
            request      => $request,
            response     => Stump::Response->new,
            match_result => $match_result,
            not_found_handler => $opts->{not_found_handler},
        );
        my $match_handlers = $match_result->[0];

        if ($match_handlers->@* == 1) {
            my $res; # ReturnType
            try {
                $res = $match_handlers->[0][0][0]->($c);
            }
            catch ($err) {
                return $self->error_handler($err, $c);
            }

            return $res // $c->not_found();
            # TODO Promise
        }

        # TODO compose handlers

        $c->not_found();
    }

    method error_handler($err, $c) {
        if (blessed($err) && $err->can('get_response')) {
            return $err->get_response();
        }

        warn $err;
        return $c->text(500, 'Internal Server Error');
    }

    method not_found($handler) {
        $not_found_handler = $handler;
        return $self;
    }

    method router($r = undef) {
        if ($r) { $router = $r }
        $router;
    }

    method get($path, $handler) {
        # TODO HEAD method request
        add_route($self, 'get', $path, $handler);
    }

    method post($path, $handler) {
        add_route($self, 'post', $path, $handler);
    }

    method put($path, $handler) {
        add_route($self, 'put', $path, $handler);
    }

    method delete($path, $handler) {
        add_route($self, 'delete', $path, $handler);
    }

    method patch($path, $handler) {
        add_route($self, 'patch', $path, $handler);
    }

    method options($path, $handler) {
        add_route($self, 'options', $path, $handler);
    }



    method psgi() {
        sub ($env) {
            my $req = Stump::Request->new(env => $env);
            my $res = dispatch($self, $req, {
                not_found_handler => $not_found_handler,
            });
            $res->finalize;
        }
    }

    method get_path($request) {
        # TODO: base path
        $request->path;
    }

    method test_request($http_request) {
        require Stump::Test;
        my $test = Stump::Test->new(app => $self);
        my $res = $test->request($http_request);
        $res;
    }
}
