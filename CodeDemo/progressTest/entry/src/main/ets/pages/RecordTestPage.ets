import { promptAction } from '@kit.ArkUI';


// 定义课程类型，使用联合类型限制可选值
type Course = 'Math' | 'Chinese' | 'English';


// 定义学生成绩记录类型（使用interface）
interface StudentCourseGrade {
  Math: number;
  Chinese: number;
  English: number;
}

// 定义班级成绩记录类型
type ClassGrades = Record<string, StudentCourseGrade>;

// 创建学生成绩对象实例
let student1: StudentCourseGrade = {
  Math: 90,
  Chinese: 85,
  English: 92
};

let student2: StudentCourseGrade = {
  Math: 78,
  Chinese: 82,
  English: 85
};

let student3: StudentCourseGrade = {
  Math: 95,
  Chinese: 89,
  English: 90
};

// 初始化班级成绩记录
const classGrades: ClassGrades = {
  '001': student1,
  '002': student2,
  '003': student3
};

@Entry
@Component
struct Index {


  /**
   * 判断班级中是否存在指定学生ID
   * @param studentId - 要检查的学生ID
   * @returns 如果存在返回true，否则返回false
   */
  hasStudentId(studentId: string): boolean {
    // 将classGrades断言为Object，然后使用Object.keys()
    return Object.keys(classGrades as Object).includes(studentId);
  }

  /**
   * 判断学生是否有特定课程的成绩记录
   * @param studentId - 学生ID
   * @param course - 课程名称
   * @returns 如果存在该课程成绩记录返回true，否则返回false
   */
  hasCourseRecord(studentId: string, course: Course): boolean {
    if (!this.hasStudentId(studentId)) {
      return false;
    }

    const studentGrades = classGrades[studentId];
    // 将studentGrades断言为Object，然后使用Object.keys()
    return Object.keys(studentGrades as Object).includes(course);
  }

  build() {
    Column({ space: 20 }) {
      Text('ArkTS Record 类型示例')
        .fontSize(20)
        .fontWeight(FontWeight.Bold);

      // 按钮区域
      Column({ space: 15 }) {
        Button('检查学生002是否存在')
          .onClick(() => {
            const exists = this.hasStudentId('002');

            promptAction.showToast({
              message: `学生002是否存在: ${exists}`
            });

          })

        Button('检查学生003是否有数学成绩')
          .onClick(() => {
            const hasRecord = this.hasCourseRecord('003', 'Math');

            promptAction.showToast({
              message: `学生003是否有数学成绩: ${hasRecord}`
            });
          })

        Button('检查学生004是否存在')
          .onClick(() => {
            const exists = this.hasStudentId('004');
            promptAction.showToast({
              message: `学生004是否存在: ${exists}`
            });
          })
      }
      .width('90%')
    }
    .width('100%')
    .height('100%')
    .padding(15)
  }
}