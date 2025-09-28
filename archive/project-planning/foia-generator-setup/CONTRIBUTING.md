# Contributing to FOIA Generator

Thank you for your interest in contributing to the FOIA Generator project! This tool empowers transparency advocates by providing AI-powered, jurisdiction-compliant public records request generation.

## 🎯 **Mission Alignment**

All contributions must align with our core mission: **Empower citizens, journalists, and advocates to effectively exercise their rights under transparency laws through professional, evidence-based tools and guidance.**

## 📋 **Types of Contributions**

### **High-Priority Contributions**
1. **FOIA Request Examples** - Help build our 918-example training dataset
2. **Legal Review** - Validate statutory compliance and professional language
3. **User Testing** - Test tools with real transparency advocacy scenarios
4. **Documentation** - Improve guides, API docs, and user resources

### **Technical Contributions**
- API development and optimization
- AI model training and fine-tuning
- Database integration and performance
- Testing framework and validation
- Deployment and infrastructure improvements

### **Content Contributions**
- Professional request templates and examples
- Jurisdiction-specific guidance and best practices
- Success stories and case studies
- Educational resources and tutorials

## 🔍 **Quality Standards**

### **Professional Language Requirements**
All contributions must follow our [Language Guidelines](docs/LANGUAGE_GUIDELINES.md):

#### **✅ Use Professional, Analytical Language:**
- "Statutory provisions may create opportunities for delay"
- "Procedural complexities can present challenges"
- "Strategic advocacy can overcome barriers"
- "Evidence-based analysis suggests"

#### **❌ Avoid Adversarial or Accusatory Language:**
- "Agencies exploit statutory gaps"
- "Laws are designed to obstruct"
- "Government systematically blocks access"
- "Transparency is fundamentally broken"

### **Legal Accuracy Standards**
- All statutory citations must be current and accurate
- Examples must comply with jurisdiction-specific requirements
- Professional legal language and formatting required
- Attorney review required for all legal content

### **Technical Quality Standards**
- Comprehensive testing required for all code contributions
- API documentation must be complete and accurate
- Performance benchmarks must be maintained or improved
- Security best practices must be followed

## 📊 **FOIA Example Contribution Guidelines**

### **Example Quality Checklist**
Each FOIA example must meet these standards:

#### **Authenticity Requirements**
- [ ] **Realistic Scenario**: Would a real person make this request?
- [ ] **Appropriate Demographics**: Persona matches request complexity
- [ ] **Legitimate Purpose**: Clear justification for records sought
- [ ] **Reasonable Scope**: Appropriate breadth for persona and situation

#### **Legal Compliance Requirements**
- [ ] **Correct Citations**: Accurate transparency law references
- [ ] **Complete Elements**: All legally required components included
- [ ] **Proper Format**: Jurisdiction-specific formatting followed
- [ ] **Accurate Contacts**: Correct agency addresses and procedures

#### **Training Data Requirements**
- [ ] **Consistent Structure**: Standardized format for AI training
- [ ] **Natural Language**: Varied but professional expression
- [ ] **Clear Outcomes**: Success criteria and expected challenges
- [ ] **Strategic Guidance**: Navigation tips for common obstacles

### **Example Template Structure**
```json
{
  "jurisdiction": "state_name",
  "persona": {
    "type": "personal_records_seeker|community_advocate|journalist|attorney|researcher|business",
    "demographics": "Age, profession, location, motivation",
    "experience_level": "novice|intermediate|advanced"
  },
  "request": {
    "category": "high_volume|specialized|complex",
    "record_type": "Specific records sought",
    "time_period": "Date range or timeframe",
    "agency": "Correct agency name and contact",
    "statutory_basis": "Relevant transparency law citations",
    "request_text": "Complete professional request language",
    "submission_method": "online|mail|email|fax",
    "fee_handling": "Payment or waiver language"
  },
  "expected_outcomes": {
    "likely_challenges": ["common obstacles"],
    "success_indicators": ["criteria for successful response"],
    "appeal_strategy": "next steps if initially denied",
    "timeline_estimate": "expected response timeframe"
  },
  "validation": {
    "attorney_reviewed": true,
    "jurisdiction_verified": true,
    "user_tested": false,
    "last_updated": "YYYY-MM-DD"
  }
}
```

## 🛠️ **Development Setup**

### **Prerequisites**
- Python 3.9+ with pip and virtualenv
- PostgreSQL 12+ for database
- Redis 6+ for caching
- Git for version control
- OpenAI API access for AI integration

### **Local Development Setup**
```bash
# Clone repository
git clone https://github.com/The-HOLE-Foundation/foia-generator.git
cd foia-generator

# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate  # Linux/Mac
# or
venv\Scripts\activate  # Windows

# Install dependencies
pip install -r requirements.txt

# Set up environment variables
cp .env.example .env
# Edit .env with your configuration

# Initialize database
python scripts/setup/init_database.py

# Run tests
pytest tests/

# Start development server
python src/main.py
```

### **Testing Requirements**
All contributions must include appropriate tests:

- **Unit Tests**: Component-level functionality
- **Integration Tests**: Service interactions and API endpoints
- **Example Validation**: FOIA example quality and compliance
- **Performance Tests**: Response time and throughput benchmarks

## 📝 **Contribution Process**

### **Step 1: Issue Creation**
1. Search existing issues to avoid duplicates
2. Create detailed issue with clear problem description
3. Include relevant labels (bug, enhancement, example, documentation)
4. Wait for maintainer review and guidance before starting work

### **Step 2: Development**
1. Fork repository and create feature branch
2. Follow code style and quality standards
3. Include comprehensive tests and documentation
4. Ensure all existing tests continue to pass

### **Step 3: Submission**
1. Create pull request with detailed description
2. Link to relevant issue number
3. Include testing evidence and validation results
4. Request review from appropriate maintainers

### **Step 4: Review Process**
1. **Automated Testing**: All tests must pass
2. **Code Review**: Technical quality and standards compliance
3. **Content Review**: Language guidelines and professional standards
4. **Legal Review**: For examples and statutory content (when applicable)

## 👥 **Community Guidelines**

### **Professional Standards**
- Maintain respectful, collaborative communication
- Focus on constructive feedback and solution development
- Support other contributors with helpful guidance and resources
- Follow our Code of Conduct in all community interactions

### **Transparency and Accountability**
- Be transparent about limitations and areas for improvement
- Acknowledge sources and give credit for contributions
- Document decisions and rationale for significant changes
- Maintain open communication about project direction and priorities

### **Educational Approach**
- Help new contributors understand standards and expectations
- Share knowledge and expertise with community members
- Create learning opportunities for skill development
- Foster inclusive environment for diverse skill levels and backgrounds

## 🎯 **Priority Contribution Areas**

### **Immediate Needs (High Priority)**
1. **Federal FOIA Examples**: 6 examples across all persona types
2. **Top State Examples**: California, Texas, New York, Florida (6 examples each)
3. **API Development**: Core request generation endpoints
4. **Legal Review Network**: Attorney volunteers for example validation

### **Medium-Term Needs (Medium Priority)**
1. **Regional State Coverage**: 15 additional states with examples
2. **AI Model Training**: Fine-tuning and optimization
3. **User Interface Integration**: React platform connection
4. **Performance Optimization**: Database and caching improvements

### **Long-Term Needs (Lower Priority)**
1. **Complete State Coverage**: Remaining 32 states with examples
2. **Advanced Features**: Success tracking, appeals support
3. **Third-Party Integrations**: External API connections
4. **International Expansion**: Adaptation for other jurisdictions

## 📊 **Recognition and Attribution**

### **Contribution Recognition**
- All contributors acknowledged in project documentation
- Significant contributions highlighted in release notes
- Regular contributor status and enhanced community privileges
- Professional references and recommendations available

### **Attribution Standards**
- Code contributions attributed through Git commit history
- Example contributions credited in data attribution files
- Documentation improvements acknowledged in change logs
- Community contributions recognized in project communications

## 📞 **Getting Help**

### **Community Support**
- **GitHub Discussions**: General questions and community interaction
- **GitHub Issues**: Bug reports, feature requests, and technical problems
- **Documentation**: Comprehensive guides and API documentation
- **Professional Network**: Connections with transparency advocacy community

### **Maintainer Contact**
- **Technical Issues**: Create GitHub issue with detailed problem description
- **Legal Questions**: Request attorney review through designated channels
- **Community Concerns**: Contact project maintainers through appropriate channels
- **Partnership Inquiries**: Professional collaboration and integration opportunities

## 📜 **Legal and Ethical Considerations**

### **Content Standards**
- All content must support lawful exercise of transparency rights
- No promotion of illegal activities or harassment
- Respect for privacy and legitimate confidentiality concerns
- Professional standards maintained in all communications and documentation

### **Intellectual Property**
- All contributions must be original work or properly attributed
- Contributors grant appropriate licenses for use in project
- Respect for third-party copyrights and intellectual property
- Clear documentation of sources and permissions

---

## 🙏 **Thank You**

Your contributions help build a more transparent and accountable government by empowering citizens, journalists, and advocates with professional-quality tools and resources. Every contribution, whether code, content, testing, or community support, makes a meaningful difference in advancing government transparency and democratic accountability.

**THE HOLE FOUNDATION - FOIA GENERATOR**
*Professional. Evidence-Based. Community-Driven.*