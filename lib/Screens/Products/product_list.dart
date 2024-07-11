import '../../constant.dart';
import '../../currency.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../GlobalComponents/button_global.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/Provider/product_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile_pos/Screens/Products/update_product.dart';

class ProductList extends StatefulWidget {
  const ProductList({Key? key}) : super(key: key);

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  TextEditingController serach = TextEditingController();
  String productPicture =
      'https://firebasestorage.googleapis.com/v0/b/maanpos.appspot.com/o/Customer%20Picture%2FNo_Image_Available.jpeg?alt=media&token=3de0d45e-0e4a-4a7b-b115-9d6722d5031f';

  var Filterdata = [];
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, __) {
        final providerData = ref.watch(productProvider);
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            title: Text(
              lang.S.of(context).productList,
              style: GoogleFonts.inter(
                color: Colors.black,
              ),
            ),
            centerTitle: true,
          ),
          body: providerData.when(data: (products) {
            return products.isNotEmpty
                ? Column(
                    children: [
                      TextField(
                        onChanged: ((value) {
                          setState(() {
                            Filterdata = products
                                .where((element) => element.productName
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          });

                          print("filterdata" + Filterdata.toString());
                          print(value.toString());
                        }),
                        controller: serach,
                        decoration: InputDecoration(
                          hintText: 'Search product name',
                          // Add a clear button to the search bar
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () => serach.clear(),
                          ),
                          // Add a search icon or button to the search bar
                          prefixIcon: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {
                              // Perform the search here
                            },
                          ),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ).paddingSymmetric(horizontal: 15),
                      Expanded(
                        child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            // physics: const NeverScrollableScrollPhysics(),
                            itemCount: serach.text.isNotEmpty
                                ? Filterdata.length
                                : products.length,
                            itemBuilder: (_, i) {
                              serach.text.isNotEmpty
                                  ? Filterdata.sort((a, b) =>
                                      a.productName.compareTo(b.productName))
                                  : products.sort((a, b) =>
                                      a.productName.compareTo(b.productName));
                              return ListTile(
                                onTap: () {
                                  UpdateProduct(productModel: products[i])
                                      .launch(context);
                                },
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(50.0),
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    // decoration: BoxDecoration(
                                    //     borderRadius: const BorderRadius.all(
                                    //         Radius.circular(90)),
                                    //     image: DecorationImage(
                                    //       image: NetworkImage(
                                    //         products[i].productPicture,
                                    //       ),
                                    //       fit: BoxFit.cover,
                                    //     )),
                                    child: CachedNetworkImage(
                                      imageUrl: products[i].productPicture,
                                      placeholder: (context, url) =>
                                          const SizedBox(
                                        height: 50,
                                        width: 50,
                                      ),
                                      errorWidget: (context, url, error) =>
                                          ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(50.0),
                                              child: Image.network(
                                                  productPicture)),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                title: Text(Filterdata.length > 0
                                    ? Filterdata[i].productName
                                    : products[i].productName),
                                subtitle: Text(
                                    "${lang.S.of(context).stock} : ${products[i].productStock}"),
                                trailing: Text(
                                  "$currency ${products[i].productSalePrice}",
                                  style: const TextStyle(fontSize: 18),
                                ),
                              );
                            }),
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      lang.S.of(context).addProduct,
                      maxLines: 2,
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0),
                    ),
                  );
          }, error: (e, stack) {
            return Text(e.toString());
          }, loading: () {
            return const Center(child: CircularProgressIndicator());
          }),
          bottomNavigationBar: ButtonGlobal(
            iconWidget: Icons.add,
            buttontext: lang.S.of(context).addNewProduct,
            iconColor: Colors.white,
            buttonDecoration: kButtonDecoration.copyWith(color: kMainColor),
            onPressed: () {
              Navigator.pushNamed(context, '/AddProducts');
            },
          ),
        );
      },
    );
  }
}
