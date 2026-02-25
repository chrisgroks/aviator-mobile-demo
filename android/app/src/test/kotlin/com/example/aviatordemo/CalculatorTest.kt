package com.example.aviatordemo

import org.junit.Assert.assertEquals
import org.junit.Assert.assertThrows
import org.junit.Test

class CalculatorTest {

    private val calculator = Calculator()

    @Test
    fun `add returns sum of two numbers`() {
        assertEquals(5.0, calculator.add(2.0, 3.0), 0.001)
    }

    @Test
    fun `subtract returns difference`() {
        assertEquals(1.0, calculator.subtract(3.0, 2.0), 0.001)
    }

    @Test
    fun `multiply returns product`() {
        assertEquals(6.0, calculator.multiply(2.0, 3.0), 0.001)
    }

    @Test
    fun `divide returns quotient`() {
        assertEquals(2.0, calculator.divide(6.0, 3.0), 0.001)
    }

    @Test
    fun `divide by zero throws exception`() {
        assertThrows(IllegalArgumentException::class.java) {
            calculator.divide(1.0, 0.0)
        }
    }

    @Test
    fun `version returns non-empty string`() {
        assert(calculator.version().isNotEmpty())
    }
}
