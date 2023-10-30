const std = @import("std");
const stdin = std.io.getStdIn().reader();

const CalculatorError = error{ DivisionByZeroError, ModByZeroError, InvalidOperationError, InvalidInputError };

const Operation = struct { operator: u8, a: f64, b: f64 };

const Calculator = struct {
    operation: u8 = undefined,
    result: f64 = 0,
    a: f64 = 0,
    b: f64 = 0,

    pub fn setNumbers(self: *@This(), a: f64, b: f64) void {
        self.a = a;
        self.b = b;
    }

    pub fn setOperation(self: *@This(), operation: u8) void {
        self.operation = operation;
    }

    pub fn estimate(self: *@This()) CalculatorError!f64 {
        switch (self.operation) {
            '+' => {
                self.result = self.a + self.b;
            },
            '-' => {
                self.result = self.a - self.b;
            },
            '*' => {
                self.result = self.a * self.b;
            },
            '/' => {
                if (self.b == 0) return CalculatorError.DivisionByZeroError;

                self.result = self.a / self.b;
            },
            '%' => {
                if (self.b == 0) return CalculatorError.ModByZeroError;

                self.result = @mod(self.a, self.b);
            },
            else => {
                return CalculatorError.InvalidOperationError;
            },
        }

        self.a = self.result;

        return self.result;
    }
};

fn get_input(isNext: bool) !Operation {
    var operation: Operation = undefined;

    var operatorBuffer: [2]u8 = undefined;
    var numberBuffer: [64]u8 = undefined;

    std.debug.print("Enter operator (+,-,*,/,%): ", .{});

    if (try stdin.readUntilDelimiterOrEof(operatorBuffer[0..], '\n')) |input| {
        operation.operator = input[0];
    } else {
        return CalculatorError.InvalidInputError;
    }

    if(!isNext){
        std.debug.print("Enter a: ", .{});

        if (try stdin.readUntilDelimiterOrEof(numberBuffer[0..], '\n')) |number| {
            operation.a = try std.fmt.parseFloat(f64, number);
        } else {
            return CalculatorError.InvalidInputError;
        }
    }

    std.debug.print("Enter b: ", .{});

    if (try stdin.readUntilDelimiterOrEof(numberBuffer[0..], '\n')) |number| {
        operation.b = try std.fmt.parseFloat(f64, number);
    } else {
        return CalculatorError.InvalidInputError;
    }

    return operation;
}

fn ask_step() !bool{
    var stepBuffer: [2]u8 = undefined;
    
    std.debug.print("Continue (y/n)?: ", .{});

    if (try stdin.readUntilDelimiterOrEof(stepBuffer[0..], '\n')) |input| {
        if(std.mem.eql(u8, input, "y")){
            return true;
        }else if(std.mem.eql(u8, input, "n")){
            return false;
        }else{
            return CalculatorError.InvalidInputError;
        }
    } else {
        return CalculatorError.InvalidInputError;
    }
}

pub fn main() !void {
    var calculator: Calculator = undefined;
    
    var operation = try get_input(false);

    calculator.setOperation(operation.operator);
    calculator.setNumbers(operation.a, operation.b);

    var result: f64 = try calculator.estimate();

    std.debug.print("The result: {d}\n", .{result});

    while(try ask_step()){
        operation = try get_input(true);

        calculator.setOperation(operation.operator);
        calculator.setNumbers(calculator.result, operation.b);

        result = try calculator.estimate();

        std.debug.print("The result: {d}\n", .{result});
    }
    
}
