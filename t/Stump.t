use v5.40;
use Test2::V0;

use Stump;
use HTTP::Request::Common;

subtest 'GET Request' => sub {
    subtest 'without middleware' => sub {
        my $app = Stump->new;

        $app->get('/hello', sub ($c) {
            $c->res->code(200);
            $c->res->body('hello');
            $c->res;
        });

        $app->get('/hello-with-shortcuts', sub ($c) {
            $c->header('X-Custom', 'This is Stump');
            $c->html(201, '<h1>Stump!!!</h1>');
        });

        subtest 'GET /hello is ok', sub {
            my $res = $app->test_request(GET '/hello');
            is $res->code, 200;
            is $res->content, 'hello';
        };

        subtest 'GET /hello-with-shortcuts is ok', sub {
            my $res = $app->test_request(GET '/hello-with-shortcuts');
            is $res->code, 201;
            is $res->header('X-Custom'), 'This is Stump';
            is $res->content, '<h1>Stump!!!</h1>';
        };
    }
};

done_testing;
