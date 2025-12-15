# Sexual Harassment Management Application

[![Status](https://img.shields.io/badge/Status-Prototype-blue)](https://github.com/) 
[![License](https://img.shields.io/badge/License-MIT-green)](https://github.com/)
[![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Mobile-orange)](https://github.com/)

A secure, confidential, and accessible digital platform designed to facilitate the reporting, management, and resolution of sexual harassment cases within institutions and organizations. 

**"Speak Up. We are here to listen."**

---

## Project Overview

The **Sexual Harassment Management Application** addresses the critical need for a safe and trusted reporting mechanism. Traditional methods often fail due to lack of anonymity, fear of retaliation, and inefficient processing. This system leverages modern technology to provide:

- **Victim Protection:** Anonymous reporting and secure data handling.
- **Accountability:** Transparent case tracking and management for administrators.
- **Efficiency:** Streamlined workflows from reporting to resolution.

## Key Features

### For Victims & Witnesses
- **Anonymous Reporting:** Submit reports without revealing identity if desired.
- **Evidence Upload:** Securely attach images, documents, or text evidence.
- **Real-time Tracking:** Monitor the status of your case (Pending, Under Review, Resolved).
- **Instant Support:** Access to emergency contacts, counseling, and medical services.

### For Administrators
- **Secure Dashboard:** Role-based access to manage incoming cases.
- **Case Management:** Tools to assign investigations, update statuses, and add notes.
- **Analytics:** Generate reports to identify trends and improve institutional policies.

## Technology Stack

### Current Prototype
The current version acts as a high-fidelity frontend prototype to demonstrate user flows and UI/UX.
- **Frontend:** HTML5, CSS3, JavaScript
- **Styling:** Tailwind CSS (via CDN)
- **Icons:** Google Material Symbols
- **Fonts:** Inter, Noto Sans

### Planned Architecture (Full Implementation)
- **Frontend (Mobile/Web):** Flutter / React
- **Backend API:** Django (Python) / Node.js
- **Database:** PostgreSQL / MySQL
- **Authentication:** JWT / OAuth2 with strictly Role-Based Access Control (RBAC)

## Project Structure

The repository organizes the prototype features into distinct modules:

| Directory | Description |
|-----------|-------------|
| `1/`      | **Home Dashboard:** Main landing page for logged-in users. |
| `2/`      | **Report Incident (Step 1):** Initial reporting screen (Incident Description). |
| `3/`      | **Report Incident (Step 2):** Evidence upload and details. |
| ...       | *Additional modules for settings, support, and admin views.* |

## Getting Started

To view the prototype locally:

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/sexual-harassment-management-app.git
    ```
2.  **Navigate to the project directory:**
    ```bash
    cd sexual-harassment-management-app
    ```
3.  **Open the Prototype:**
    - Open `1/code.html` in your web browser to see the **Home Dashboard**.
    - Open `2/code.html` to see the **Reporting Flow**.

## Security & Privacy

Security is the cornerstone of this application.
- **Encryption:** All sensitive headers and data are encrypted at rest and in transit.
- **Anonymity:** The system is designed to strip metadata from anonymous reports.
- **Compliance:** Adheres to institutional data protection standards and ethical guidelines.

## Contributing

Contributions are welcome! Please follow these steps:
1.  Fork the repository.
2.  Create a feature branch (`git checkout -b feature/AmazingFeature`).
3.  Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4.  Push to the branch (`git push origin feature/AmazingFeature`).
5.  Open a Pull Request.

## License

Distributed under the MIT License. See `LICENSE` for more information.

---
*Empowering safer environments through technology.*