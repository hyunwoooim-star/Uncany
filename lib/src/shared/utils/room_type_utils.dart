import 'package:flutter/material.dart';
import 'package:uncany/src/core/constants/period_times.dart';

/// 교실 유형별 아이콘 유틸리티
class RoomTypeUtils {
  RoomTypeUtils._();

  /// RoomType enum에서 아이콘 반환
  static IconData getIconFromEnum(RoomType type) {
    return getIcon(type.code);
  }

  /// RoomType enum에서 색상 반환
  static Color getColorFromEnum(RoomType type) {
    return getColor(type.code);
  }

  /// 교실 유형에 따른 아이콘 반환
  static IconData getIcon(String? roomType) {
    switch (roomType?.toLowerCase()) {
      case 'computer':
      case '컴퓨터실':
        return Icons.computer;
      case 'science':
      case '과학실':
        return Icons.science;
      case 'music':
      case '음악실':
        return Icons.music_note;
      case 'art':
      case '미술실':
        return Icons.palette;
      case 'gym':
      case '체육관':
        return Icons.fitness_center;
      case 'library':
      case '도서관':
        return Icons.local_library;
      case 'meeting':
      case '회의실':
        return Icons.groups;
      case 'lab':
      case '실험실':
        return Icons.biotech;
      case 'cooking':
      case '조리실':
        return Icons.restaurant;
      case 'workshop':
      case '공작실':
        return Icons.construction;
      default:
        return Icons.meeting_room;
    }
  }

  /// 교실 유형에 따른 색상 반환
  static Color getColor(String? roomType) {
    switch (roomType?.toLowerCase()) {
      case 'computer':
      case '컴퓨터실':
        return Colors.blue;
      case 'science':
      case '과학실':
        return Colors.green;
      case 'music':
      case '음악실':
        return Colors.purple;
      case 'art':
      case '미술실':
        return Colors.orange;
      case 'gym':
      case '체육관':
        return Colors.red;
      case 'library':
      case '도서관':
        return Colors.brown;
      case 'meeting':
      case '회의실':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
