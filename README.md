# Hospital Finder

A full-stack app for finding nearby hospitals, viewing their details, and booking appointments.

- **Frontend:** Flutter mobile app (`/frontend`)
- **Backend:** Node.js + Express REST API with MongoDB (`/backend`)

## Features

- Find hospitals near your current location
- Search hospitals by name or keyword
- View hospital details and open them on Google Maps
- Book, confirm and cancel appointments
- Download a booking confirmation as a PDF
- Bulk-import hospital data from an Excel file

## Tech Stack

| Part     | Technologies                                                                 |
|----------|------------------------------------------------------------------------------|
| Frontend | Flutter, Provider, Geolocator, Google Maps Flutter, HTTP, Shared Preferences |
| Backend  | Node.js, Express, MongoDB, Mongoose, Multer, PDFKit, SheetJS (xlsx)          |

## Project Structure

```
hospital-finder/
├── backend/
│   ├── server.js
│   ├── package.json
│   └── .env.example
├── frontend/
│   ├── lib/
│   ├── android/
│   ├── ios/
│   ├── web/
│   └── pubspec.yaml
└── README.md
```

## Getting Started

### Prerequisites

- [Node.js](https://nodejs.org/) 18 or newer
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart `^3.7.2`)
- A MongoDB database (local or [MongoDB Atlas](https://www.mongodb.com/atlas))
- A Google Maps API key (for the map screen)

### 1. Backend setup

```bash
cd backend
npm install
```

Create a `.env` file in the `backend` folder (copy `.env.example`) and fill it in:

```env
MONGODB_URI=your_mongodb_connection_string
PORT=3000
NODE_ENV=development
FRONTEND_URL=http://localhost:3000
ALLOWED_ORIGINS=http://localhost:3000
```

Start the server:

```bash
npm run dev     # development, auto-restarts with nodemon
npm start       # production
```

The API runs at `http://localhost:3000`.

### 2. Frontend setup

```bash
cd frontend
flutter pub get
flutter run
```

Point the app at your backend by setting the API base URL in the Flutter code:

- Android emulator: `http://10.0.2.2:3000`
- iOS simulator: `http://localhost:3000`
- Real device: `http://<your-computer-ip>:3000` (same Wi-Fi network)

Add your Google Maps API key in `android/app/src/main/AndroidManifest.xml` (and the iOS config). Do not commit real keys to the repo.

## API Endpoints

### Health

| Method | Endpoint      | Description         |
|--------|---------------|---------------------|
| GET    | `/api/health` | Server health check |

### Hospitals

| Method | Endpoint                  | Description                                   |
|--------|---------------------------|-----------------------------------------------|
| GET    | `/api/hospitals`          | List hospitals                                |
| GET    | `/api/hospitals/nearby`   | Hospitals near a given location               |
| GET    | `/api/hospitals/search`   | Search hospitals                              |
| GET    | `/api/hospitals/stats`    | Hospital statistics                           |
| GET    | `/api/hospitals/:id`      | Details of one hospital                       |
| POST   | `/api/hospitals/upload`   | Import hospitals from a file (multipart form) |

### Bookings

| Method | Endpoint                                  | Description                   |
|--------|-------------------------------------------|-------------------------------|
| POST   | `/api/bookings`                           | Create a booking              |
| GET    | `/api/bookings/:id`                       | Get a booking                 |
| POST   | `/api/bookings/:id/confirm`               | Confirm a booking             |
| POST   | `/api/bookings/:id/cancel`                | Cancel a booking              |
| GET    | `/api/bookings/:id/download-confirmation` | Download the confirmation PDF |

## Security Notes

- Never commit your `.env` file. It is listed in `.gitignore`.
- Keep API keys and database credentials out of the repository.
- If a key was ever committed or shared, revoke it and create a new one.

## Contributing

1. Fork the repository
2. Create a branch: `git checkout -b feature/your-feature`
3. Commit your changes and open a pull request

## License

ISC
