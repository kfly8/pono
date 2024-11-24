use Pono;
use Types::Standard -types;

my $app = Pono->new(
    Variables => {
        foo => Int,
    }
);

$app->get('/', sub ($c) {
    my $foo = $c->req->query('foo');
    $c->set('foo', $foo);

    $c->text(HTTP_OK, "Hello $foo!")
});

$app->psgi;
