#!/usr/bin/env python3
"""
Test suite for Data Integrity Validation System
Demonstrates the validator in action with test cases
"""

import json
import tempfile
import shutil
from pathlib import Path
import sys
import os
import importlib.util

# Add scripts/validation directory to path
script_dir = Path(__file__).parent.absolute()

# Import the validator module (has hyphens, so use importlib)
validator_path = script_dir / "validate-against-ground-truth.py"
spec = importlib.util.spec_from_file_location("validator", validator_path)
validator_module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(validator_module)

GroundTruthValidator = validator_module.GroundTruthValidator
ConflictSeverity = validator_module.ConflictSeverity

class TestDataIntegrityValidation:
    """Test cases for the validation system"""
    
    def setup_test_environment(self):
        """Create temporary test environment"""
        self.test_dir = Path(tempfile.mkdtemp())
        self.ground_truth_file = self.test_dir / "ground-truth.json"
        self.test_data_file = self.test_dir / "test-data.json"
        
        # Create ground truth
        # Create ground truth
        ground_truth = {
            "_schema_version": "v0.11",
            "_last_updated": "2025-10-02",
            "california": {
                "response_timeline_days": 10,
                "response_timeline_type": "business_days",
                "statute_citation": "California Government Code § 7920.000",
                "verified_date": "2025-09-26",
                "confidence_level": "high"
            },
            "texas": {
                "response_timeline_days": 10,
                "response_timeline_type": "business_days",
                "statute_citation": "Texas Government Code § 552.221",
                "verified_date": "2025-09-26",
                "confidence_level": "high"
            },
            "federal": {
                "response_timeline_days": 20,
                "response_timeline_type": "working_days",
                "statute_citation": "5 U.S.C. § 552(a)(6)(A)(i)",
                "verified_date": "2025-09-26",
                "confidence_level": "high"
            }
        }
        
        with open(self.ground_truth_file, 'w') as f:
            json.dump(ground_truth, f, indent=2)
        
        print(f"✅ Test environment created: {self.test_dir}")
        return self.test_dir
    
    def cleanup_test_environment(self):
        """Clean up temporary test files"""
        if hasattr(self, 'test_dir') and self.test_dir.exists():
            shutil.rmtree(self.test_dir)
            print(f"🧹 Test environment cleaned up")
    
    def test_matching_data(self):
        """Test Case 1: Data matches ground truth - should PASS"""
        print("\n" + "="*70)
        print("TEST 1: Data Matches Ground Truth")
        print("="*70)
        
        # Create matching data
        test_data = {
            "jurisdiction_info": {
                "jurisdiction_name": "california"
            },
            "response_requirements": {
                "response_timeline_days": 10,
                "response_timeline_type": "business_days"
            },
            "statute_details": {
                "statute_citation": "California Government Code § 7920.000"
            }
        }
        
        with open(self.test_data_file, 'w') as f:
            json.dump(test_data, f, indent=2)
        
        validator = GroundTruthValidator(self.ground_truth_file)
        passed, conflicts = validator.validate_file(self.test_data_file)
        
        assert passed, "Validation should pass for matching data"
        assert len(conflicts) == 0, "No conflicts expected"
        print("✅ PASS: Data validated successfully")
        return True
    
    def test_conflicting_timeline(self):
        """Test Case 2: Response timeline mismatch - should FAIL"""
        print("\n" + "="*70)
        print("TEST 2: Response Timeline Conflict (10 vs 20 days)")
        print("="*70)
        
        # Create conflicting data
        test_data = {
            "jurisdiction_info": {
                "jurisdiction_name": "california"
            },
            "response_requirements": {
                "response_timeline_days": 20,  # Ground truth says 10
                "response_timeline_type": "business_days"
            },
            "statute_details": {
                "statute_citation": "California Government Code § 7920.000"
            }
        }
        
        with open(self.test_data_file, 'w') as f:
            json.dump(test_data, f, indent=2)
        
        validator = GroundTruthValidator(self.ground_truth_file)
        passed, conflicts = validator.validate_file(self.test_data_file)
        
        assert not passed, "Validation should fail for conflicting data"
        assert len(conflicts) > 0, "Conflicts should be detected"
        assert conflicts[0].severity == ConflictSeverity.CRITICAL, "Should be CRITICAL"
        
        print(f"❌ FAIL (Expected): {len(conflicts)} conflict(s) detected")
        validator.print_conflicts()
        print("✅ PASS: Conflict correctly detected and blocked")
        return True
    
    def test_type_mismatch(self):
        """Test Case 3: Data type mismatch - should FAIL"""
        print("\n" + "="*70)
        print("TEST 3: Data Type Mismatch (int vs string)")
        print("="*70)
        
        # Create data with wrong type
        test_data = {
            "jurisdiction_info": {
                "jurisdiction_name": "california"
            },
            "response_requirements": {
                "response_timeline_days": "10",  # String instead of int
                "response_timeline_type": "business_days"
            },
            "statute_details": {
                "statute_citation": "California Government Code § 7920.000"
            }
        }
        
        with open(self.test_data_file, 'w') as f:
            json.dump(test_data, f, indent=2)
        
        validator = GroundTruthValidator(self.ground_truth_file)
        passed, conflicts = validator.validate_file(self.test_data_file)
        
        assert not passed, "Validation should fail for type mismatch"
        print(f"❌ FAIL (Expected): Type mismatch detected")
        validator.print_conflicts()
        print("✅ PASS: Type mismatch correctly detected")
        return True
    
    def test_missing_jurisdiction(self):
        """Test Case 4: Jurisdiction not in ground truth - should SKIP"""
        print("\n" + "="*70)
        print("TEST 4: Unknown Jurisdiction (not in ground truth)")
        print("="*70)
        
        # Create data for jurisdiction not in ground truth
        test_data = {
            "jurisdiction_info": {
                "jurisdiction_name": "new_york"  # Not in ground truth
            },
            "response_requirements": {
                "response_timeline_days": 5,
                "response_timeline_type": "business_days"
            }
        }
        
        with open(self.test_data_file, 'w') as f:
            json.dump(test_data, f, indent=2)
        
        validator = GroundTruthValidator(self.ground_truth_file)
        passed, conflicts = validator.validate_file(self.test_data_file)
        
        assert passed, "Validation should skip unknown jurisdictions"
        assert len(conflicts) == 0, "No conflicts for unknown jurisdiction"
        print("✅ PASS: Unknown jurisdiction correctly skipped")
        return True
    
    def run_all_tests(self):
        """Run all test cases"""
        print("\n" + "="*70)
        print("DATA INTEGRITY VALIDATION - TEST SUITE")
        print("="*70)
        
        try:
            self.setup_test_environment()
            
            results = []
            results.append(("Matching Data", self.test_matching_data()))
            results.append(("Timeline Conflict", self.test_conflicting_timeline()))
            results.append(("Type Mismatch", self.test_type_mismatch()))
            results.append(("Unknown Jurisdiction", self.test_missing_jurisdiction()))
            
            print("\n" + "="*70)
            print("TEST SUMMARY")
            print("="*70)
            
            for test_name, result in results:
                status = "✅ PASS" if result else "❌ FAIL"
                print(f"{status}: {test_name}")
            
            all_passed = all(result for _, result in results)
            
            if all_passed:
                print("\n🎉 All tests passed! Validation system working correctly.")
                return 0
            else:
                print("\n❌ Some tests failed. Review results above.")
                return 1
                
        finally:
            self.cleanup_test_environment()

def main():
    """Run the test suite"""
    tester = TestDataIntegrityValidation()
    exit_code = tester.run_all_tests()
    sys.exit(exit_code)

if __name__ == "__main__":
    main()
