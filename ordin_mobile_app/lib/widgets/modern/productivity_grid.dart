import 'package:flutter/material.dart';
import '../../theme/modern_dark_colors.dart';
import '../../theme/modern_dark_spacing.dart';

/// Productivity Grid Widget - habit tracker style grid visualization
/// Matches reference design pixel-perfect
class ProductivityGrid extends StatelessWidget {
  final int rows;
  final int columns;
  final List<GridCellState> cellStates;
  
  const ProductivityGrid({
    super.key,
    this.rows = 5,
    this.columns = 7,
    required this.cellStates,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(rows, (rowIndex) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: rowIndex < rows - 1 ? ModernDarkSpacing.gridGap : 0,
          ),
          child: Row(
            children: List.generate(columns, (colIndex) {
              final cellIndex = rowIndex * columns + colIndex;
              final state = cellIndex < cellStates.length
                  ? cellStates[cellIndex]
                  : GridCellState.empty;
              
              return Padding(
                padding: EdgeInsets.only(
                  right: colIndex < columns - 1 ? ModernDarkSpacing.gridGap : 0,
                ),
                child: _buildGridCell(state),
              );
            }),
          ),
        );
      }),
    );
  }
  
  Widget _buildGridCell(GridCellState state) {
    return Container(
      width: ModernDarkSpacing.gridItemWidth,
      height: ModernDarkSpacing.gridItemHeight,
      decoration: BoxDecoration(
        color: _getCellColor(state),
        borderRadius: BorderRadius.circular(4.0),
        border: state == GridCellState.empty
            ? Border.all(
                color: ModernDarkColors.patternLight.withOpacity(0.3),
                width: 1.5,
              )
            : null,
      ),
      child: state == GridCellState.striped
          ? CustomPaint(
              painter: _MiniStripePainter(),
            )
          : null,
    );
  }
  
  Color _getCellColor(GridCellState state) {
    switch (state) {
      case GridCellState.filled:
        return ModernDarkColors.patternDark;
      case GridCellState.striped:
        return ModernDarkColors.patternLight.withOpacity(0.3);
      case GridCellState.empty:
        return Colors.transparent;
    }
  }
}

enum GridCellState {
  filled,
  striped,
  empty,
}

class _MiniStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ModernDarkColors.patternDark.withOpacity(0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    for (double i = -size.width; i < size.width * 2; i += 4) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
