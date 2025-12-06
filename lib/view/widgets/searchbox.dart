import 'package:amba_new/cubit/users/users_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchBox extends StatefulWidget {
  const SearchBox({Key? key}) : super(key: key);

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  late TextEditingController _searchBoxController;
  @override
  void initState() {
    _searchBoxController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _searchBoxController.dispose();
  }

  _onSearchBoxChanged(String input) {
    context.read<UsersCubit>().searchBoxChanged(input);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 25.0, left: 10.0, right: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pesquisar',
            key: Key('pokeSearchBox_title'),
            style: TextStyle(fontSize: 19.0),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: TextField(
                key: const Key('pokeSearchBox_textField'),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      width: 0.5,
                      color: Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      width: 0.5,
                      color: Colors.grey,
                    ),
                  ),
                  hintText: 'Nome ou número de sócio',
                ),
                controller: _searchBoxController,
                keyboardType: TextInputType.text,
                onChanged: (input) {
                  _onSearchBoxChanged(input);
                }),
          ),
        ],
      ),
    );
  }
}
