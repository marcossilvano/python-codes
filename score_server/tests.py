
def print_unpack(name: str, age: int, **kwargs):
    print("name: " + name)
    print("age: " + str(age))

if __name__ == "__main__":
    dct = {"name": "john_doe", "age": 45, "email": "john.doe@mail.com"}

    print_unpack(**dct)