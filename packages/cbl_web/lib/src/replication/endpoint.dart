abstract class Endpoint {}

class UrlEndpoint extends Endpoint {
  UrlEndpoint(this.url);
  final Uri url;

  @override
  String toString() => 'UrlEndpoint($url)';
}
