package main

import (
	"bufio"
	"encoding/binary"
	"fmt"
	"github.com/sergeymakinen/go-bmp"
	"os"
	"strconv"
	"strings"
)

// https://hexed.it/ - win hex online для отладки
// https://convertio.co/ru/download/3eb420b60905d521c5fddea429a873ea4dae95/ - конвентер png в bmp

// _ = binary.Write(file, binary.LittleEndian, data.vertexes[i][j])

type pixel struct {
	r byte
	g byte
	b byte
	a byte
}

type LettersData struct {
	height     uint32
	width      uint32
	bytesCount uint32
	pixels     []pixel
}

func initStructure(data *LettersData) {
	data.pixels = make([]pixel, 0)
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

	var data LettersData
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
	return (p.r == 0) && (p.g == 0) && (p.b == 0)
}

func GetData(f *os.File, pixelWH int, data *LettersData) {
	img, _ := bmp.Decode(f)
	data.height = uint32(img.Bounds().Max.Y)
	data.width = uint32(img.Bounds().Max.X)
	data.bytesCount = 4 * data.height * data.width

	for i := 0; i < int(data.height); i++ {
		for j := 0; j < int(data.width); j++ {
			r, g, b := img.At(j, i).GetRGB()
			if r == 0 && g == 0 && b == 0 {
				data.pixels = append(data.pixels, pixel{0, 0, 0, 0})
			} else {
				data.pixels = append(data.pixels, pixel{r, g, b, 255})
			}

		}
	}
}

func saveData(file *os.File, data *LettersData) {
	_ = binary.Write(file, binary.LittleEndian, data.height)
	_ = binary.Write(file, binary.LittleEndian, data.width)
	_ = binary.Write(file, binary.LittleEndian, data.bytesCount)
	for _, p := range data.pixels {
		_ = binary.Write(file, binary.LittleEndian, p.r)
		_ = binary.Write(file, binary.LittleEndian, p.g)
		_ = binary.Write(file, binary.LittleEndian, p.b)
		_ = binary.Write(file, binary.LittleEndian, p.a)
	}
}
