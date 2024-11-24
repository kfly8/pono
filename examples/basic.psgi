use Pono;

my $app = Pono->new;
$app->get('/', sub ($c) {
    $c->text(HTTP_OK, 'Hello Pono!')
});

$app->get('/json', sub ($c) {
    $c->json(HTTP_OK, { hello => '世界'})
});

$app->get('/redirect', sub ($c) {
    $c->redirect('/')
});

$app->get('/die', sub ($c) {
    die 'oops!!'
});

$app->not_found(sub ($c) {
    $c->text(404, 'Custom Not Found')
});

$app->psgi;
