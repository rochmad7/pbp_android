part of 'pages.dart';

class SearchView extends StatefulWidget {
  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  TextEditingController keywordController = TextEditingController();

  List<Post> posts;
  var items = List<Post>();

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  void fetchData() async {
    final response = await http.get(baseURLAPI + 'post');
    if (response.statusCode == 200) {
      setState(() {
        var data = jsonDecode(response.body);

        posts =
            (data['post'] as Iterable).map((e) => Post.fromJson(e)).toList();
      });
    }
  }

  void filterSearchResults(String query) {
    List<Post> dummySearchList = List<Post>();
    dummySearchList.addAll(posts);
    if (query.isNotEmpty) {
      List<Post> dummyListData = List<Post>();
      dummySearchList.forEach((item) {
        if (containsIgnoreCase(item.judul, query)) {
          dummyListData.add(item);
        }
      });
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(posts);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostCubit, PostState>(
      builder: (_, state) {
        if (state is PostLoaded) {
          return Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (value) {
                      filterSearchResults(value);
                    },
                    controller: keywordController,
                    decoration: InputDecoration(
                        labelText: "Search",
                        hintText: "Cari Artikel",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(25.0)))),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemBuilder: (context, index) {
                      var post = items[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReadPostView(post: post),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 145.0,
                          margin: EdgeInsets.symmetric(
                              horizontal: 18.0, vertical: 8.0),
                          child: SecondaryCard(post: post),
                        ),
                      );
                    },
                  ),
                  // child: ListView.builder(
                  //   shrinkWrap: true,
                  //   itemCount: items.length,
                  //   itemBuilder: (context, index) {
                  //     var posts = items[index];
                  //     return ListTile(
                  //       title: Text(posts.judul),
                  //     );
                  //   },
                  // ),
                ),
              ],
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
