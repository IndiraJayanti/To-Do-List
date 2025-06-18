import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

const String graphqlEndpoint = 'http://localhost:8080/query';

GraphQLClient _createGraphQLClient({required String uri, String? token}) {
  Link link = HttpLink(uri);

  if (token != null && token.isNotEmpty) {
    link = AuthLink(getToken: () async => 'Bearer $token').concat(link);
  }

  return GraphQLClient(
    cache: GraphQLCache(store: InMemoryStore()),
    link: link,
  );
}

class MyGraphQLProvider extends StatefulWidget {
  final Widget child;
  final String? initialToken;

  const MyGraphQLProvider({super.key, required this.child, this.initialToken});

  static _MyGraphQLProviderState of(BuildContext context) {
    final _MyGraphQLProviderState? result = context
        .findAncestorStateOfType<_MyGraphQLProviderState>();
    if (result != null) {
      return result;
    }
    throw FlutterError(
      'MyGraphQLProviderState not found. Make sure MyGraphQLProvider is an ancestor.',
    );
  }

  @override
  State<MyGraphQLProvider> createState() => _MyGraphQLProviderState();
}

class _MyGraphQLProviderState extends State<MyGraphQLProvider> {
  late ValueNotifier<GraphQLClient> clientNotifier;

  @override
  void initState() {
    super.initState();
    clientNotifier = ValueNotifier(
      _createGraphQLClient(uri: graphqlEndpoint, token: widget.initialToken),
    );
  }

  void updateToken(String? newToken) {
    // Membuat ulang clientNotifier dengan token baru
    clientNotifier.value = _createGraphQLClient(
      uri: graphqlEndpoint,
      token: newToken,
    );
    clientNotifier.value.cache.store.reset();
    print("GraphQL Client updated with new token: $newToken");
  }

  @override
  void didUpdateWidget(covariant MyGraphQLProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialToken != oldWidget.initialToken) {
      updateToken(widget.initialToken);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(client: clientNotifier, child: widget.child);
  }
}
