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

        my $res = $app->test_request(GET '/hello');
        is $res->code, 200;
        is $res->content, 'hello';
    }
};

done_testing;
