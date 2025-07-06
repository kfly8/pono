use v5.42;
use experimental qw(class);

class Pono::Router {
    method add($method, $path, $handler) { ... }
    method match($method, $path) { ... }
}
