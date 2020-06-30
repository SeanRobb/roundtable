import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import RolePopup from './rolePopup';

describe('<RolePopup />', () => {
  test('it should mount', () => {
    render(<RolePopup />);
    
    const RolePopup = screen.getByTestId('RolePopup');

    expect(RolePopup).toBeInTheDocument();
  });
});