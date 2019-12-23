import 'package:date_format/date_format.dart';

class DateUtil {
  static String getNewChatTime(DateTime timesamp) {
    String result = "";
    DateTime todayDateTime = DateTime(2019,12,24);
    DateTime otherDataTime = timesamp;

    bool yearTemp = todayDateTime.year == otherDataTime.year;
    if (yearTemp) {
      int todayMonth = todayDateTime.month;
      int otherMonth = otherDataTime.month;
      if (todayMonth == otherMonth) {
        //表示是同一个月
        int temp = todayDateTime.day - otherDataTime.day;
        print("$temp getNewChatTime:$timesamp,$result");

        switch (temp) {
          case 0:
            result = formatDate(timesamp, [HH, ':', mm]);
            break;
          case 1:
            result = "昨天 " + formatDate(timesamp, [HH, ':', mm]);
            break;
          case 2:
          case 3:
          case 4:
          case 5:
          case 6:
          default:
            int dayOfMonth = getWeekIndexInYear(otherDataTime);
            int todayOfMonth = getWeekIndexInYear(todayDateTime);

            if (dayOfMonth == todayOfMonth) {
              //表示是同一周
              int dayOfWeek = otherDataTime.weekday;
              if (dayOfWeek != 1) {
                //判断当前是不是星期日   如想显示为：周日 12:09 可去掉此判断
                result = formatDate(timesamp, [D, HH, ':', mm]);
              } else {
                result = formatDate(timesamp, [D, HH, ':', mm]);
              }
            } else {
              result = formatDate(timesamp, [M, '月', d, '日', HH, ':', mm]);

            }
            break;
//          default:
//            result = formatDate(timesamp, [HH, ':', mm]);
            break;
        }
      } else {
        result = formatDate(timesamp, [M, '月', d, '日', HH, ':', mm]);
      }
    } else {
      result = formatDate(timesamp, [yyyy, '年', M, '月', d, '日', HH, ':', mm]);
    }

    print("getNewChatTime:$timesamp,$result");
    return result;
  }

  static int getWeekIndexInYear(DateTime dateTime) {
    DateTime firstDayOfWeek = DateTime(dateTime.year, 1, 1);
    Duration duration = dateTime.difference(firstDayOfWeek);
    return duration.inDays ~/ 7;
  }
}
