use Stump;

my $app = Stump->new;
$app->get('/', sub ($c) {
    $c->text(HTTP_OK, 'Hello Stump!')
});

$app->get('/json', sub ($c) {
    $c->json(HTTP_OK, { hello => '世界'})
});

$app->psgi;
