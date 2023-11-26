package main

import (
	"bufio"
	"encoding/binary"
	"fmt"
	"os"
	"strconv"
	"unsafe"
)

// https://hexed.it/ - win hex online для отладки
// Тот самый выбор в начале:
type tIndex = uint8 //Можно заменить на uint8 или uint32

type tFragmet struct {
	setsCount int16
	setData   [][3]tIndex //max = 65535 (uint16) //max = 255 (uint8)
}

type mobjData struct {
	vertexCount        uint32
	vertexes           [][3]float32
	normalCount        uint32
	normals            [][3]float32
	textureCordCount   uint32
	textureCords       [][2]float32
	vCount             uint32
	fragmentBytesCount uint32
	fragmentCount      uint32
	fragments          []tFragmet
}

func initStructure(data *mobjData) {
	data.vertexes = make([][3]float32, 0)
	data.normals = make([][3]float32, 0)
	data.textureCords = make([][2]float32, 0)
	data.fragments = make([]tFragmet, 0)
}

func lineAnalize(str string, data *mobjData) {
	switch str[:2] {
	case "v ":
		var vec3 = vertex3Analyze(str)
		data.vertexes = append(data.vertexes, vec3)
		data.vertexCount++
	case "vn":
		var vec3 = vertex3Analyze(str)
		data.normals = append(data.normals, vec3)
		data.normalCount++
	case "vt":
		var vec2 = vertex2Analyze(str)
		data.textureCords = append(data.textureCords, vec2)
		data.textureCordCount++
	case "f ":
		fragmentAnalyze(str, data)
	}
}

func main() {
	input := bufio.NewScanner(os.Stdin)
	fmt.Print("Введите название объекта (без формата): ")
	input.Scan()
	objName := input.Text()

	in, err := os.Open("ObjectsIn/" + objName + ".obj")
	if err != nil {
		fmt.Println("Файл не найден")
		return
	}

	var data mobjData
	initStructure(&data)

	scanner := bufio.NewScanner(in)
	for scanner.Scan() {
		line := scanner.Text()
		lineAnalize(line, &data)
	}

	var fragmentBytesCount uint32
	var bytesCount = 3 * uint32(unsafe.Sizeof(data.fragments[0].setData[0][0]))
	for i := 0; i < len(data.fragments); i++ {
		data.vCount += uint32(data.fragments[i].setsCount - 2)
		fragmentBytesCount += uint32(data.fragments[i].setsCount)*bytesCount + 2
	}
	data.fragmentBytesCount = fragmentBytesCount
	data.vCount *= 3

	fmt.Println("Полученные данные: ")
	fmt.Println(data)
	in.Close()

	out, err := os.Create("ObjectsOut/" + objName + ".mobj")
	if err != nil {
		fmt.Println("Создание файла не удалось")
		return
	}

	saveData(out, &data)
	out.Close()
	fmt.Println("Данные сохранены в '" + "ObjectsOut/" + objName + ".mobj'")
}

func vertex3Analyze(str string) [3]float32 {
	var VertexVec [3]float32
	str += " "
	var i int
	for i = 1; str[i-1] != ' '; i++ {
	}
	for v := 0; v < 3; v++ {
		var vertex = ""
		for str[i+1] != ' ' {
			vertex += string(str[i])
			i++
		}
		f64, _ := strconv.ParseFloat(vertex, 32)
		VertexVec[v] = float32(f64)
		i += 2
	}
	return VertexVec
}

func vertex2Analyze(str string) [2]float32 {
	var VertexVec [2]float32
	str += " "
	var i int
	for i = 1; str[i-1] != ' '; i++ {
	}
	for v := 0; v < 2; v++ {
		var vertex = ""
		for str[i] != ' ' {
			vertex += string(str[i])
			i++
		}
		f64, _ := strconv.ParseFloat(vertex, 32)
		VertexVec[v] = float32(f64)
		i++
	}
	return VertexVec
}

func fragmentAnalyze(str string, data *mobjData) {
	var fragment tFragmet
	fragment.setData = make([][3]tIndex, 0)
	str += " "

	var i int
	for i = 1; str[i-1] != ' '; i++ {
	}
	for i != len(str) {
		var indexVec [3]tIndex
		for v := 0; v < 3; v++ {
			var index = ""
			for (str[i] != ' ') && (str[i] != '/') {
				index += string(str[i])
				i++
			}
			var i64, _ = strconv.ParseInt(index, 10, 64)
			indexVec[v] = tIndex(i64)
			i++
		}
		fragment.setsCount++
		fragment.setData = append(fragment.setData, indexVec)

		for i != len(str) && str[i-1] != ' ' {
			i++
		}
	}

	data.fragmentCount++
	data.fragments = append(data.fragments, fragment)
}

func saveData(file *os.File, data *mobjData) {
	_ = binary.Write(file, binary.LittleEndian, data.vertexCount)
	for i := 0; i < len(data.vertexes); i++ {
		for j := 0; j < 3; j++ {
			_ = binary.Write(file, binary.LittleEndian, data.vertexes[i][j])
		}
	}
	_ = binary.Write(file, binary.LittleEndian, data.normalCount)
	for i := 0; i < len(data.normals); i++ {
		for j := 0; j < 3; j++ {
			_ = binary.Write(file, binary.LittleEndian, data.normals[i][j])
		}
	}
	_ = binary.Write(file, binary.LittleEndian, data.textureCordCount)
	for i := 0; i < len(data.textureCords); i++ {
		for j := 0; j < 2; j++ {
			_ = binary.Write(file, binary.LittleEndian, data.textureCords[i][j])
		}
	}

	_ = binary.Write(file, binary.LittleEndian, data.vCount)
	_ = binary.Write(file, binary.LittleEndian, data.fragmentBytesCount)
	_ = binary.Write(file, binary.LittleEndian, data.fragmentCount)
	for i := 0; i < len(data.fragments); i++ {
		_ = binary.Write(file, binary.LittleEndian, data.fragments[i].setsCount)
		for j := 0; j < len(data.fragments[i].setData); j++ {
			for k := 0; k < 3; k++ {
				_ = binary.Write(file, binary.LittleEndian, data.fragments[i].setData[j][k])
			}
		}
	}

}
