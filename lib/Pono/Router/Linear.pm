use v5.42;
use experimental qw(class);

class Pono::Router::Linear :isa(Pono::Router) {
    field $routes = [];

    my $empty_params = {};

    method add($method, $path, $handler) {
        push $routes->@*, [$method, $path, $handler];
    }

    method match($method, $path) {
        my $handlers = [];
        for my $r ($routes->@*) {
            my ($route_method, $route_path, $handler) = $r->@*;
            if ($route_method ne $method) {
                next;
            }
            if ($route_path eq '*' || $route_path eq '/*') {
                push $handlers->@*, [$handler, $empty_params];
            }

            my $has_star = index($route_path, '*') != -1;
            my $has_label = index($route_path, ':') != -1;
            if (!$has_star && !$has_label) {
                if ($route_path eq $path || $route_path . '/' eq $path) {
                    push $handlers->@*, [$handler, $empty_params];
                }
            }
            elsif ($has_star && !$has_label) {
                ...
            }
            elsif (!$has_star && $has_label) {
                ...
            }
            else {
                ...
            }
        }
        return [$handlers];
    }


}
