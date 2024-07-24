use lib 'lib';

use Stump;
use Future::AsyncAwait;

my $app = Stump->new();

$app->get('/', async sub ($c) {
    $c->text(HTTP_OK, "Hello World!")
});

$app->psgi;
