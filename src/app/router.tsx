import { createBrowserRouter } from 'react-router';
import { TrackingPage } from '../features/client-tracking/TrackingPage';
import { LoginPage } from '../features/dealer-panel/LoginPage';
import { PanelHomePage } from '../features/dealer-panel/PanelHomePage';
import { RequireStaff } from '../features/dealer-panel/RequireStaff';
import { StartPage } from '../features/request-form/StartPage';
import { Layout } from './Layout';
import { NotFoundPage } from './NotFoundPage';

export const router = createBrowserRouter([
  {
    element: <Layout />,
    children: [
      { path: '/', element: <StartPage /> },
      { path: '/seguimiento', element: <TrackingPage /> },
      { path: '/panel/ingresar', element: <LoginPage /> },
      {
        path: '/panel',
        element: <RequireStaff />,
        children: [{ index: true, element: <PanelHomePage /> }],
      },
      { path: '*', element: <NotFoundPage /> },
    ],
  },
]);
