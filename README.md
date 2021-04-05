The request body parser middleware for [Dia](https://github.com/unger1984/dia).
Parse query, x-www-form-urlencoded, json and form-data params and uploaded files form HttpRequest.

## Usage:

A simple usage example:

```dart
class ContextWithBody extends Context with ParsedBody {
  ContextWithBody(HttpRequest request) : super(request);
}

void main() {
  final app = App<ContextWithBody>();

  app.use(body());

  app.use((ctx, next) async {
    ctx.body = ''' 
    query=${ctx.query}
    parsed=${ctx.parsed}
    files=${ctx.files}
    ''';
  });

  /// Start server listen on localhsot:8080
  app
      .listen('localhost', 8080)
      .then((info) => print('Server started on http://localhost:8080'));
}
```

## Named params:

* `uploadDirectory` - directory for upload files. Default: `Directory.systemTemp`

## Use with:

* [dia](https://github.com/unger1984/dia) - A simple dart http server in Koa2 style.
* [dia_router](https://github.com/unger1984/dia_router) - Middleware like as koa_router.
* [dia_cors](https://github.com/unger1984/dia_cors) - CORS middleware.
* [dia_static](https://github.com/unger1984/dia_static) - Package to serving static files.

## Features and bugs:

I will be glad for any help and feedback!
Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/unger1984/dia_body/issues
