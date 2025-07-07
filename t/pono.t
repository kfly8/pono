use v5.42;
use utf8;
use Test2::V0;

use Pono;
use HTTP::Request::Common;

subtest 'GET Request' => sub {
    subtest 'without middleware' => sub {
        my $app = Pono->new;

        $app->get('/hello', sub ($c) {
            $c->res->code(200);
            $c->res->body('hello');
            $c->res;
        });

        $app->get('/hello-with-shortcuts', sub ($c) {
            $c->header('X-Custom', 'This is Pono');
            $c->html(201, '<h1>Pono!!!</h1>');
        });

        $app->get('/hello-json', sub ($c) {
            $c->json(200, { HELLO => '🪵' });
        });

        subtest 'GET http://localhost/hello is ok', sub {
            my $res = $app->request(GET 'http://localhost/hello');
            is $res->code, 200;
            is $res->content, 'hello';
        };

        subtest 'GET httphello is ng', sub {
            my $res = $app->request(GET 'httphello');
            is $res->code, 404;
        };

        subtest 'GET /hello is ok', sub {
            my $res = $app->request(GET '/hello');
            is $res->code, 200;
            is $res->content, 'hello';
        };

        subtest 'GET hello is ok', sub {
            my $res = $app->request(GET 'hello');
            is $res->code, 200;
            is $res->content, 'hello';
        };

        subtest 'GET /hello-with-shortcuts is ok', sub {
            my $res = $app->request(GET '/hello-with-shortcuts');
            is $res->code, 201;
            is $res->header('X-Custom'), 'This is Pono';
            is $res->content, '<h1>Pono!!!</h1>';
        };

        subtest 'GET / is not found', sub {
            my $res = $app->request(GET '/');
            is $res->code, 404;
        };

        subtest 'GET /hello-json', sub {
            my $res = $app->request(GET '/hello-json');
            is $res->code, 200;
            is $res->json, { HELLO => '🪵' };
        };
    }
};

subtest 'HEAD method', sub {
    my $app = Pono->new;

    $app->get('/page', sub ($c) {
        $c->header('X-Message', 'Foo');
        $c->header('X-Method', $c->req->method);
        $c->text(200, '/page');
    });

    subtest 'it should return 200 response with body - GET /page', sub {
        my $res = $app->request(GET '/page');
        is $res->code, 200;
        is $res->header('X-Message'), 'Foo';
        is $res->header('X-Method'), 'GET';
        is $res->content, '/page';
    };

    subtest 'it should return 200 response without body - HEAD /page', sub {
        my $res = $app->request(HEAD '/page');
        is $res->code, 200;
        is $res->header('X-Message'), 'Foo';
        is $res->header('X-Method'), 'HEAD';
        is $res->content, '', 'body should be empty';
    };
};

done_testing;
