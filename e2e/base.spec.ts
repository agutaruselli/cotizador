import { expect, test } from '@playwright/test';

// Smoke tests for slice 1. Texts are kept in sync with src/i18n/es.ts.

test('home shows the referential quote notice (RF-10)', async ({ page }) => {
  await page.goto('/');
  await expect(page.getByRole('heading', { name: 'Vendé tu auto usado' })).toBeVisible();
  await expect(page.getByRole('complementary', { name: 'La cotización es referencial' })).toBeVisible();
});

test('tracking link shows the request status (RF-13)', async ({ page }) => {
  await page.goto('/seguimiento#demo-local-token-00000000000000000000000000');
  await expect(page.getByText('Recibida')).toBeVisible();
});

test('tracking link with a wrong token shows not found (RF-13)', async ({ page }) => {
  await page.goto('/seguimiento#AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
  await expect(page.getByText('No encontramos tu solicitud')).toBeVisible();
});

test('panel redirects to sign in without a session (RF-32)', async ({ page }) => {
  await page.goto('/panel');
  await expect(page.getByRole('heading', { name: 'Ingreso de la automotora' })).toBeVisible();
});

test('dealer user signs in and sees its requests (RF-32, RF-33)', async ({ page }) => {
  await page.goto('/panel/ingresar');
  await page.getByLabel('Correo').fill('dealer@example.com');
  await page.getByLabel('Contraseña').fill('local-dev-password');
  await page.getByRole('button', { name: 'Ingresar' }).click();

  await expect(page.getByRole('heading', { name: 'Solicitudes' })).toBeVisible();
  await expect(page.getByRole('cell', { name: 'Recibida' })).toBeVisible();
});

test('wrong password shows an error (RF-32)', async ({ page }) => {
  await page.goto('/panel/ingresar');
  await page.getByLabel('Correo').fill('dealer@example.com');
  await page.getByLabel('Contraseña').fill('not-the-password');
  await page.getByRole('button', { name: 'Ingresar' }).click();

  await expect(page.getByText('El correo o la contraseña no son correctos.')).toBeVisible();
});
