import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            blurRadius: 14,
            color: Color(0x12000000),
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 34),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: const Column(
              children: <Widget>[
                Align(alignment: Alignment.centerLeft, child: _WaterIcon()),
                SizedBox(height: 24),
                Text(
                  'AquaTrack',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'SISTEM ADMINISTRASI AIR',
                  style: TextStyle(
                    color: Color(0xFFD9EFFF),
                    fontSize: 11,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: -24,
            child: Center(
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      blurRadius: 14,
                      color: Color(0x17000000),
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_clock_outlined,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterIcon extends StatelessWidget {
  const _WaterIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.water_drop_outlined,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}
