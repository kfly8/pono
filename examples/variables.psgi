use Pono;
use Types::Standard -types;

my $app = Pono->new(
    Variables => {
        message => Str,
    }
);

$app->get('/', sub ($c) {
    my $message = $c->req->query('message');
    $c->set('message', $message);

    $c->text(HTTP_OK, "Hello $message!")
});

$app->psgi;
