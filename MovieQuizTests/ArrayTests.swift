// фреймворк для тестирования
import XCTest
// импортируем приложение для тестирования
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    // тест на успешное взятие элемента по индексу
    func testGetValueInRange() throws {
        let array = [1, 1, 2, 3, 5]
        
        let value = array[safe: 2]
        
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    // тест на взятие элемента по неправильному индексу
    func testGetValueOutOfRange() throws {
        let array = [1, 1, 2, 3, 5]
            
        let value = array[safe: 20]
        
        XCTAssertNil(value)
    }
}
