import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  final List<String> selectedBrands;
  final double minPrice;
  final double maxPrice;
  final String? sortBy;
  final String? selectedGender;
  final List<String> selectedColors;

  FilterBottomSheet({
    this.selectedBrands = const [],
    this.minPrice = 0,
    this.maxPrice = 1750,
    this.sortBy,
    this.selectedGender,
    this.selectedColors = const [],
  });

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  List<String> _selectedBrands = [];
  RangeValues _priceRange = const RangeValues(0, 1750);
  String? _sortBy;
  String? _selectedGender;
  List<String> _selectedColors = [];

  @override
  void initState() {
    super.initState();
    _selectedBrands = widget.selectedBrands;
    _priceRange = RangeValues(widget.minPrice, widget.maxPrice);
    _sortBy = widget.sortBy;
    _selectedGender = widget.selectedGender;
    _selectedColors = widget.selectedColors;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.75,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                _buildSectionTitle('Brands'),
                const SizedBox(height: 10),
                _buildBrands(),
                const SizedBox(height: 20),
                _buildSectionTitle('Price Range'),
                RangeSlider(
                  values: _priceRange,
                  activeColor: Colors.black,
                  inactiveColor: Colors.white,
                  min: 0,
                  max: 1750,
                  divisions: 35,
                  labels: RangeLabels(
                    '\$${_priceRange.start.toStringAsFixed(0)}',
                    '\$${_priceRange.end.toStringAsFixed(0)}',
                  ),
                  onChanged: (values) {
                    setState(() {
                      _priceRange = values;
                    });
                  },
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Sort By'),
                _buildSortBy(),
                const SizedBox(height: 20),
                _buildSectionTitle('Gender'),
                _buildGender(),
                const SizedBox(height: 20),
                _buildSectionTitle('Color'),
                _buildColors(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _selectedBrands.clear();
                            _priceRange = const RangeValues(0, 1750);
                            _sortBy = null;
                            _selectedGender = null;
                            _selectedColors.clear();
                          });
                        },
                        child: const Text('RESET ALL'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.black),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 100,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, {
                            'brands': _selectedBrands,
                            'minPrice': _priceRange.start,
                            'maxPrice': _priceRange.end,
                            'sortBy': _sortBy,
                            'gender': _selectedGender,
                            'colors': _selectedColors,
                          });
                        },
                        child: const Text('APPLY'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildBrands() {
    final brands = [
      {
        'name': 'Nike',
        'logo':
            'https://static.vecteezy.com/system/resources/thumbnails/019/956/200/small/nike-transparent-nike-free-free-png.png'
      },
      {
        'name': 'Puma',
        'logo':
            'https://w7.pngwing.com/pngs/527/442/png-transparent-puma-logo-iron-on-adidas-brand-adidas-mammal-cat-like-mammal-carnivoran.png'
      },
      {
        'name': 'Adidas',
        'logo':
            'https://static.vecteezy.com/system/resources/thumbnails/010/994/239/small_2x/adidas-logo-black-symbol-clothes-design-icon-abstract-football-illustration-with-white-background-free-vector.jpg'
      },
      {
        'name': 'Reebok',
        'logo':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRqNvTGZn70t_SIvAGA8srVoiaB6Fket2eg1g&s'
      },
      {
        'name': 'Vans',
        'logo':
            'https://e7.pngegg.com/pngimages/718/502/png-clipart-vans-t-shirt-logo-shoe-brand-t-shirt-angle-text.png'
      },
      {
        'name': 'Jordan',
        'logo':
            'https://logos-world.net/wp-content/uploads/2020/04/Air-Jordan-Logo.png'
      },
    ];

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: brands.length,
        itemBuilder: (context, index) {
          final brand = brands[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ChoiceChip(
              checkmarkColor: Colors.white,
              avatar: CircleAvatar(
                backgroundImage: NetworkImage(brand['logo']!),
                backgroundColor: Colors.white,
              ),
              label: Text(brand['name']!),
              selected: _selectedBrands.contains(brand['name']),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedBrands.add(brand['name']!);
                  } else {
                    _selectedBrands.remove(brand['name']);
                  }
                });
              },
              selectedColor: Colors.black,
              backgroundColor: Colors.grey[200],
              labelStyle: TextStyle(
                color: _selectedBrands.contains(brand['name'])
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortBy() {
    final sortByOptions = ['Most recent', 'Lowest price', 'Highest reviews'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sortByOptions.length,
        itemBuilder: (context, index) {
          final sort = sortByOptions[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ChoiceChip(
              checkmarkColor: Colors.white,
              label: Text(sort),
              selected: _sortBy == sort,
              onSelected: (selected) {
                setState(() {
                  _sortBy = selected ? sort : null;
                });
              },
              selectedColor: Colors.black,
              backgroundColor: Colors.grey[200],
              labelStyle: TextStyle(
                color: _sortBy == sort ? Colors.white : Colors.black,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGender() {
    final genderOptions = ['male', 'female', 'unisex'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: genderOptions.length,
        itemBuilder: (context, index) {
          final gender = genderOptions[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ChoiceChip(
              checkmarkColor: Colors.white,
              label: Text(gender),
              selected: _selectedGender == gender,
              onSelected: (selected) {
                setState(() {
                  _selectedGender = selected ? gender : null;
                });
              },
              selectedColor: Colors.black,
              backgroundColor: Colors.grey[200],
              labelStyle: TextStyle(
                color: _selectedGender == gender ? Colors.white : Colors.black,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColors() {
    final colors = [
      {'name': 'Black', 'code': '0xFF000000'},
      {'name': 'White', 'code': '0xFFFFFFFF'},
      {'name': 'Red', 'code': '0xFFFF0000'},
      {'name': 'Green', 'code': '0xFF00FF00'},
      {'name': 'Blue', 'code': '0xFF0000FF'},
      {'name': 'Yellow', 'code': '0xFFFFFF00'},
      {'name': 'Cyan', 'code': '0xFF00FFFF'},
      {'name': 'Magenta', 'code': '0xFFFF00FF'},
      {'name': 'Silver', 'code': '0xFFC0C0C0'},
      {'name': 'Gray', 'code': '0xFF808080'},
      {'name': 'Maroon', 'code': '0xFF800000'},
      {'name': 'Olive', 'code': '0xFF808000'},
      {'name': 'Purple', 'code': '0xFF800080'},
      {'name': 'Teal', 'code': '0xFF008080'},
      {'name': 'Navy', 'code': '0xFF000080'},
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final color = colors[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: FilterChip(
              checkmarkColor: Colors.white,
              avatar: CircleAvatar(
                backgroundColor: Color(int.parse(color['code']!)),
                radius: 10,
              ),
              label: Text(color['name']!),
              selected: _selectedColors.contains(color['code']),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedColors.add(color['code']!);
                  } else {
                    _selectedColors.remove(color['code']);
                  }
                });
              },
              selectedColor: Colors.black,
              backgroundColor: Colors.grey[200],
              labelStyle: TextStyle(
                color: _selectedColors.contains(color['code'])
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          );
        },
      ),
    );
  }
}
