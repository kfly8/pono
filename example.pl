use Stump;

my $app = Stump->new;
$app->get('/', sub ($c) {
    $c->text(HTTP_OK, 'Hello Stump!')
});

$app->get('/json', sub ($c) {
    $c->json(HTTP_OK, { hello => '世界'})
});

$app->get('/redirect', sub ($c) {
    $c->redirect('/')
});

$app->get('/die', sub ($c) {
    die 'die'
});

$app->not_found(sub ($c) {
    $c->text(404, 'Custom Not Found')
});

$app->on_error(sub ($err, $c) {
    if ($err isa My::Error) {
        return $err->get_response($c);
    }
    $c->text(500, 'Custom Internal Server Error')
});

$app->psgi;
