import 'dart:async';
import 'dart:io';
import 'dart:math';

class Point {
  int x;
  int y;
  Point(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point && runtimeType == other.runtimeType && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

class KadalGame {
  late int gridWidth;
  late int gridHeight;
  List<Point> kadal = [];  // Posisi kadal (kepala, tubuh, ekor)
  Point makanan; // Posisi makanan

  KadalGame() 
      : makanan = Point(0, 0) {
    updateGridSize();
    // Tempatkan kadal di tengah terminal saat dimulai
    int startX = gridWidth ~/ 2;
    int startY = gridHeight ~/ 2;
    kadal = [
      Point(startX, startY),        // Kepala
      Point(startX - 1, startY),    // Tubuh
      Point(startX - 2, startY)     // Ekor
    ];

    generateMakanan(); // Generate posisi makanan
  }

  void updateGridSize() {
    gridWidth = stdout.terminalColumns;
    gridHeight = stdout.terminalLines;

    // Pastikan ukuran minimal grid
    if (gridWidth < 20) gridWidth = 20;
    if (gridHeight < 10) gridHeight = 10;
  }

  void generateMakanan() {
    Random random = Random();
    int x, y;

    do {
      x = random.nextInt(gridWidth - 1);
      y = random.nextInt(gridHeight - 1);
    } while (kadal.contains(Point(x, y))); // Pastikan makanan tidak tumpang tindih dengan kadal

    makanan = Point(x, y); // Set posisi makanan
  }

  void start() {
    Timer.periodic(Duration(milliseconds: 200), (timer) {
      moveKadal();
      render();
    });
  }

  void moveKadal() {
    // Dapatkan posisi kepala saat ini
    Point kepala = kadal.first;
    Point newHead;

    // Tentukan arah pergerakan kadal menuju makanan
    if (kepala.x < makanan.x) {
      newHead = Point(kepala.x + 1, kepala.y); // Bergerak ke kanan
    } else if (kepala.x > makanan.x) {
      newHead = Point(kepala.x - 1, kepala.y); // Bergerak ke kiri
    } else if (kepala.y < makanan.y) {
      newHead = Point(kepala.x, kepala.y + 1); // Bergerak ke bawah
    } else {
      newHead = Point(kepala.x, kepala.y - 1); // Bergerak ke atas
    }

    // Cek apakah kadal makan makanan
    if (newHead == makanan) {
      // Tambahkan kepala baru di depan tubuh kadal
      kadal.insert(0, newHead);
      generateMakanan(); // Generate posisi makanan baru
    } else {
      // Tambahkan kepala baru di depan tubuh kadal dan buang ekor
      kadal.insert(0, newHead);
      kadal.removeLast();
    }
  }

  void render() {
    // Update ukuran terminal agar game menyesuaikan jika ukuran terminal berubah
    updateGridSize();

    // Bersihkan layar terminal
    stdout.write('\x1B[2J\x1B[0;0H');

    // Render papan permainan
    StringBuffer output = StringBuffer();
    for (int y = 0; y < gridHeight; y++) {
      for (int x = 0; x < gridWidth; x++) {
        Point currentPoint = Point(x, y);
        
        // Render kadal
        if (kadal.isNotEmpty && kadal.first == currentPoint) {
          output.write('@'); // Kepala kadal
        } else if (kadal.length > 1 && kadal.sublist(1, kadal.length - 1).contains(currentPoint)) {
          output.write('='); // Tubuh kadal
        } else if (kadal.last == currentPoint) {
          output.write('~'); // Ekor kadal
        } else if (makanan == currentPoint) {
          output.write('o'); // Makanan
        } else {
          output.write(' '); // Ruang kosong
        }
      }
      output.writeln();
    }

    // Tampilkan output di terminal
    stdout.write(output.toString());
  }
}

void main() {
  KadalGame game = KadalGame();
  game.start();
}