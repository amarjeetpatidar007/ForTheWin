# Social Media Analytics Module

A comprehensive analytics solution that analyzes social media engagement data using Langflow and DataStax Astra DB. This project was developed as part of an assignment to create a data-driven insights system for social media performance analysis.

## Project Overview

This project consists of three main components:
1. Data Generation Scripts (TypeScript)
2. Analytics Processing (Langflow)
3. Frontend Visualization (Flutter)

### Features

- Random social media engagement data generation
- Automated data storage in Astra DB
- Custom Langflow workflows for data analysis
- GPT-powered insights generation
- Interactive Flutter dashboard with:
  - Real-time data visualization
  - Engagement metrics graphs
  - Chat interface for insights

## Project Structure

```
├── workflow/
│   └── langflow/           # Langflow workflow files
│
├── app/
│   └── flutter_app/        # Flutter application source code
│       ├── lib/
│       └── ...
│
├── data_generation/
│   └── typescript/         # Data generation scripts
│
└── README.md
```

## Prerequisites

- Node.js (for TypeScript scripts)
- Flutter SDK
- DataStax Astra DB account
- Langflow installation
- OpenAI API key (for GPT integration)

## Setup Instructions

### 1. Data Generation

```bash
cd data_generation
npm install
npm run generate
```

Environment variables needed in `.env`:
```
ASTRA_DB_ID=your_database_id
ASTRA_DB_REGION=your_database_region
ASTRA_DB_KEYSPACE=your_keyspace
ASTRA_DB_TOKEN=your_token
```

### 2. Langflow Setup

1. Import the workflow from `workflow/langflow`
2. Configure your Astra DB credentials in Langflow
3. Set up your OpenAI API key in Langflow

### 3. Flutter Application

```bash
cd app/flutter_app
flutter pub get
flutter run
```

Required environment variables in `.env`:
```
ASTRA_DB_ENDPOINT=your_endpoint
ASTRA_DB_TOKEN=your_token
LANGFLOW_API_ENDPOINT=your_langflow_endpoint
```

## Features in Detail

### Data Generation
- Simulates social media engagement data
- Generates random but realistic:
  - Post types (carousel, reels, static images)
  - Engagement metrics (likes, shares, comments)
  - Audience demographics
  - Timestamps

### Langflow Workflow
- Processes engagement data
- Calculates average metrics per post type
- Integrates with GPT for insight generation
- Provides comparative analysis

### Flutter Application
- Real-time data visualization
- Interactive charts and graphs
- Chat interface for querying insights
- Responsive design for multiple screen sizes

## API Endpoints

### Astra DB
```
POST /api/json/v1/default_keyspace/social_data
GET /api/json/v1/default_keyspace/social_data
```

### Langflow
```
POST /api/v1/process
GET /api/v1/chat/{flow_id}
```

## Assignment Objectives Met

1. ✅ Data Generation & Storage
   - Created realistic social media engagement dataset
   - Successfully stored in Astra DB

2. ✅ Performance Analysis
   - Implemented Langflow workflow for data processing
   - Calculated engagement metrics by post type

3. ✅ Insight Generation
   - Integrated GPT for automated insights
   - Provided comparative analysis between post types

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details

## Acknowledgments

- DataStax for providing Astra DB
- Langflow community
- Flutter team