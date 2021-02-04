import Fluent
import Vapor

final class Employee: Model{
    static let schema = "employees"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "firstName")
    var firstName: String
    
    @Field(key: "lastName")
    var lastName: String

    init() { }

    init(id: UUID? = nil, firstName: String, lastName: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
    }
}
extension Employee: Content{}
