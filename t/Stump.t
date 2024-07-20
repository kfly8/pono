use v5.40;
use Test2::V0;

use Stump;

use Plack::Test;
use HTTP::Request::Common;

subtest 'GET Request' => sub {
    subtest 'without middleware' => sub {
        my $app = Stump->new;

        $app->get('/hello', sub ($c) {
            $c->response->code(200);
            $c->response->body('hello');
            $c->response;
        });

        test_psgi app => $app->psgi, client => sub($cb) {
            my $res = $cb->(GET '/hello');
            is $res->code, 200;
            is $res->content, 'hello';
        };
    }
};

done_testing;
