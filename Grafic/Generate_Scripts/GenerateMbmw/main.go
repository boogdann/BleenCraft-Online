package main

import (
	"bufio"
	"encoding/binary"
	"fmt"
	"github.com/sergeymakinen/go-bmp"
	"image"
	"os"
	"strconv"
	"strings"
)

// https://hexed.it/ - win hex online для отладки
// https://convertio.co/ru/download/3eb420b60905d521c5fddea429a873ea4dae95/ - конвентер png в bmp

// _ = binary.Write(file, binary.LittleEndian, data.vertexes[i][j])
// Задаёт значение для минимума значений rgb с которых пиксель считается пустым
var minForPixel byte = 252

type pixel struct {
	r byte
	g byte
	b byte
}

type row struct {
	space_l     uint16
	pixelsCount uint16
	pixels      []pixel
	space_r     uint16
}

type mbmwData struct {
	rowBytesCount uint32
	rowsCount     uint32
	rows          []row
}

func initStructure(data *mbmwData) {
	data.rows = make([]row, 0)
}

func main() {
	input := bufio.NewScanner(os.Stdin)
	fmt.Print("Введите название объекта (без формата): ")
	input.Scan()
	objName := input.Text()

	in, err := os.Open("TextureIn/" + objName + ".bmp")
	if err != nil {
		fmt.Println("Файл не найден")
		return
	}

	var pxFormat = objName[strings.LastIndex(objName, "_")+1:]
	var pixelWH, _ = strconv.Atoi(pxFormat)

	var data mbmwData
	initStructure(&data)

	//Получение данных
	GetData(in, pixelWH, &data)

	fmt.Println("Полученные данные: ")
	fmt.Println(data)
	in.Close()

	out, err := os.Create("TextureOut/" + objName + ".mbmw")
	if err != nil {
		fmt.Println("Создание файла не удалось")
		return
	}

	saveData(out, &data)
	out.Close()
	fmt.Println("Данные сохранены в '" + "TextureOut/" + objName + ".mbmw'")
}

func isPxSpace(p pixel) bool {
	return (p.r > minForPixel) && (p.g > minForPixel) && (p.b > minForPixel)
}

func GetMaxPx(i, j, pixelWH int, img image.Image) pixel {
	var m = make(map[pixel]int)
	for k, l := i, j; k < i+pixelWH; k, l = k+1, l+1 {
		r, g, b := img.At(j, i).GetRGB()
		var p = pixel{r, g, b}
		m[p]++
	}
	var maxPx pixel
	var max = 0
	for k, v := range m {
		if v > max {
			max = v
			maxPx = k
		}
	}
	return maxPx
}

func GetData(f *os.File, pixelWH int, data *mbmwData) {
	img, _ := bmp.Decode(f)
	var width = img.Bounds().Max.X
	var height = img.Bounds().Max.Y
	data.rowBytesCount = 100 * 3 * uint32(width/pixelWH)
	for i := 0; i < height; i += pixelWH {
		data.rowsCount++
		var row row
		row.pixels = make([]pixel, 0)
		var start, end int
		var isLSpace = true
		var cube int
		for j := 0; j < width; j += pixelWH {
			var CurPx = GetMaxPx(i, j, pixelWH, img)
			if !isPxSpace(CurPx) && isLSpace {
				start = cube
				isLSpace = false
				end = 0
			}
			if isPxSpace(CurPx) && !isLSpace {
				end = cube
			}
			cube++
		}
		row.space_l = uint16(start)
		if end == 0 {
			row.space_r = 0
		} else {
			row.space_r = uint16(cube - end)
		}

		cube = 0
		for j := 0; j < width; j += pixelWH {
			if (start <= cube) && ((end == 0) || cube <= end) {
				row.pixelsCount++
				var CurPx = GetMaxPx(i, j, pixelWH, img)
				row.pixels = append(row.pixels, CurPx)

			}
			cube++
		}
		data.rows = append(data.rows, row)

	}
}

func saveData(file *os.File, data *mbmwData) {
	_ = binary.Write(file, binary.LittleEndian, data.rowBytesCount)
	_ = binary.Write(file, binary.LittleEndian, data.rowsCount)
	for _, v := range data.rows {
		_ = binary.Write(file, binary.LittleEndian, v.space_l)
		_ = binary.Write(file, binary.LittleEndian, v.pixelsCount)
		for _, p := range v.pixels {
			_ = binary.Write(file, binary.LittleEndian, p.r)
			_ = binary.Write(file, binary.LittleEndian, p.g)
			_ = binary.Write(file, binary.LittleEndian, p.b)
		}
		_ = binary.Write(file, binary.LittleEndian, v.space_r)
	}
}
