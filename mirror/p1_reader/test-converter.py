import unittest
import converter

class read_results(unittest.TestCase):
    expected_output = {
            "DSRM_version":       50,
            "date_time":          1515439537.0,
            "date_time_str":      "2018-01-08 20:25:37",
            "e-serialnum":        4530303033303030303032313234383133,
            "tarif_1_delivered":  0.855,
            "tarif_2_delivered":  0.693,
            "tarif_1_returned":   0.084,
            "tarif_2_returned":   0.000,
            "actual_tarif":       2,
            "power_delivering":    0.134,
            "power_returning":     0.000,
            "total_power_fails":  8,
            "long_power_fails":   4,
            "power_fail_log":     ((1508870785.0, '2017-10-24 20:46:25', 305),),
            "voltage_sags_L1":    3,
            "voltage_sags_L2":    3,
            "voltage_sags_L3":    2,
            "voltage_swells_L1":   0,
            "voltage_swells_L2":   0,
            "voltage_swells_L3":   0,
            "text_message":       "",
            "voltage_L1":         229.0,
            "voltage_L2":         226.0,
            "voltage_L3":         229.0,
            "current_L1":         0,
            "current_L2":         0,
            "current_L3":         0,
            "power_L1_+P":        0.094,
            "power_L2_+P":        0.040,
            "power_L3_+P":        0.000,
            "power_L1_-P":        0.000,
            "power_L2_-P":        0.000,
            "power_L3_-P":        0.000,
            "device_type":        3,
            "g-serialnum":        4730303136353631323033353830313133,
            "gas_read_time":      1515441300.0,
            "gas_read_time_str":  "2018-01-08 20:55:00",
            "gas_delivered":      1.29
            }

    def test_read_frombytes(self):
        output_file = []
        with open('sample_datagram') as file:
            for line in file:
                output_file.append(line)
        output = converter.read_datagram(output_file)
        for key, value in self.expected_output.items():
            self.assertIn(key, output.keys())
            self.assertEqual(output[key], self.expected_output[key])

if __name__ == '__main__':
    unittest.main()
