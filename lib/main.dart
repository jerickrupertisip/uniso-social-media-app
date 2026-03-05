import "dart:convert";
import "dart:ui";
import "package:cached_network_image/cached_network_image.dart";
import "package:http/http.dart" as http;
import "package:shadcn_flutter/shadcn_flutter.dart";
import "package:uniso_social_media_app/models/picsum_image.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = ThemeData.dark(radius: 0.75);
    return ShadcnApp(
      darkTheme: theme,
      theme: theme,
      themeMode: ThemeMode.system,
      scaling: const AdaptiveScaling(0.85),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _Home();
}

class Scroller extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

class _Home extends State<Home> {
  final _pageController = PageController(initialPage: 0);
  final List<PicsumImage> _images = [];

  int _currentPage = 0;
  int _currentPicsumPage = 0;
  bool _isLoading = false;

  Future<List<PicsumImage>> fetchImages(int page, {int? limit = 4}) async {
    final response = await http.get(
      Uri.parse("https://picsum.photos/v2/list?page=$page&limit=$limit"),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => PicsumImage.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load images");
    }
  }

  Future<void> _fetchNextPage() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      var newImages = await fetchImages(_currentPicsumPage);

      setState(() {
        _images.addAll(newImages);
        _currentPicsumPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();

    _fetchNextPage();
    _pageController.addListener(() {
      if (_currentPage > _images.length - 2) {
        _fetchNextPage();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Container centeredCircularProgress(ThemeData theme, [double? progress]) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        size: theme.typography.x8Large.fontSize,
        value: progress,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: Scroller(),
      child: Stack(
        alignment: .center,
        children: [
          _images.isEmpty
              ? centeredCircularProgress(Theme.of(context))
              : PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: _images.length,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemBuilder: (context, index) {
                    var image = _images[index];
                    var theme = Theme.of(context);

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(theme.radiusMd),
                      child: CachedNetworkImage(
                        fadeInDuration: Duration(milliseconds: 1),
                        imageUrl: image.downloadUrl,
                        fit: BoxFit.cover,
                        progressIndicatorBuilder: (context, url, progress) {
                          return centeredCircularProgress(
                            theme,
                            progress.progress,
                          );
                        },
                        imageBuilder: (context, imageProvider) {
                          return Stack(
                            children: [
                              Positioned.fill(
                                child: Image(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                child: Padding(
                                  padding: EdgeInsets.all(theme.radiusXl),
                                  child: Text(
                                    image.author,
                                    style: TextStyle(
                                      shadows: [
                                        Shadow(
                                          offset: Offset.fromDirection(10, 2),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                  ).h1,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),

          Positioned(
            top: 0.0,
            left: 0.0,
            child: Container(
              child: Text(
                "Hello, World",
                style: TextStyle(
                  shadows: [
                    Shadow(offset: Offset.fromDirection(10, 2), blurRadius: 6),
                  ],
                ),
              ).h1,
            ).withPadding(all: Theme.of(context).radiusXl),
          ),
        ],
      ),
    ).withPadding(all: Theme.of(context).typography.small.fontSize);
  }
}
