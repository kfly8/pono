use v5.40;
use experimental qw(class);

class Stump::Router {
    method add($method, $path, $handler) { ... }
    method match($method, $path) { ... }
}
